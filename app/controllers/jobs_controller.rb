class JobsController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!
  before_action :set_job, only: %i[show edit update destroy]

  # GET /jobs or /jobs.json
  def index
    @title = 'Your Jobs'
    @pagy, @jobs = pagy(current_user.jobs)

    respond_to do |format|
      format.html

      format.turbo_stream
    end
  end

  # GET /jobs/1 or /jobs/1.json
  def show; end

  # GET /jobs/new
  def new
    @job = Job.new
    @job.build_resume
  end

  # GET /jobs/1/edit
  def edit; end

  # POST /jobs or /jobs.json
  def create
    @job = Job.new(job_params.merge(user: current_user))
    if @job.save
      @job.resume.extract_content
      # Trigger AI API call banground job with job's details
      replacements = {
        job_title: @job.title,
        resume: @job.resume.content,
        job_description: @job.description,
        company: @job.company
      }

      GenerateCoverLetterGroqAiJob.perform_async(@job.id, replacements.to_json)

      # Respond with AI response to be shown in modal
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('turbo-modal',
                                                    target: 'ai_response_for_user',
                                                    partial: 'response_modal')
        end
      end
    else
      @job.build_resume unless @job.resume
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('jobs-form',
                                                    partial: 'jobs/form',
                                                    locals: { job: @job }),
                 status: :unprocessable_entity
        end

        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    @job = Job.find(params[:id])

    if job_params[:applied].present?
      @job.applied = job_params[:applied]
      @job.save(validate: false)
      return
    end

    if @job.update(job_params.except(:title, :company, :location))
      # Trigger content extraction if the resume is updated
      @job.resume.extract_content if params[:job][:resume_attributes].present? && params[:job][:resume_attributes][:file].present?

      # Trigger the AI job if relevant fields are updated
      replacements = {
        job_title: @job.title,
        resume: @job.resume.content,
        job_description: @job.reload.description,
        company: @job.company
      }

      GenerateCoverLetterGroqAiJob.perform_async(@job.id, replacements.to_json)

      # Respond with a success message
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('turbo-modal',
                                                    target: 'ai_response_for_user',
                                                    partial: 'response_modal')
        end
      end
    else
      @job.build_resume unless @job.resume
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('jobs-form',
                                                    partial: 'jobs/form',
                                                    locals: { job: @job }),
                 status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /jobs/1 or /jobs/1.json
  def destroy
    @job.destroy!

    respond_to do |format|
      format.html { redirect_to jobs_path, status: :see_other, notice: 'Job was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_job
    @job = Job.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def job_params
    params.require(:job).permit(
      :title, :company, :location, :description, :applied,
      resume_attributes: [:file]
    )
  end
end

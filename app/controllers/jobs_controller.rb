class JobsController < ApplicationController
  before_action :set_job, only: %i[show edit update destroy]

  # GET /jobs or /jobs.json
  def index
    @jobs = Job.all
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
    @job = Job.new(job_params)
    if @job.save
      @job.resume.extract_content
      # Trigger AI API call banground job with job's details
      replacements = {
        job_title: @job.title,
        resume: @job.resume.content,
        job_description: @job.description,
        company: @job.company
      }

      CoverLetter.create!(body: 'initialize', job_id: @job.id)
      GenerateCoverLetterGroqAiJob.perform_async(@job.id, replacements.to_json)

      # Respond with AI response to be shown in modal
      render partial: 'response_modal', locals: { loading: true }
    else
      render :new
    end
  end

  def test_modal; end

  # PATCH/PUT /jobs/1 or /jobs/1.json
  def update
    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @job.errors, status: :unprocessable_entity }
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
      :title, :company, :location, :description,
      resume_attributes: [:file]
    )
  end
end

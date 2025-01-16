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
  end

  # GET /jobs/1/edit
  def edit; end

  # POST /jobs or /jobs.json
  def create
    @job = Job.new(job_params)

    if @job.save
      # Trigger AI API call with job details
      # replacements = {
      #   job_title: @job.title,
      #   resume: @job.resume,
      #   job_description: @job.description,
      #   company: @job.company
      # }

      # prompt = PromptGenerator.generate(replacements)

      # ai_service = GroqAiApiService.new(prompt)
      # ai_service.call

      # Respond with AI response to be shown in modal
      respond_to do |format|
        format.html { render partial: 'ai_response', locals: { ai_response: 'Cool beans' } }
        # format.turbo_stream do
        #   render turbo_stream: turbo_stream.update('turbo-modal', partial: 'ai_response',
        #                                                           locals: { ai_response: ai_response['choices'][0]['message']['content'] })
        # end
      end
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
    params.expect(job: %i[title company location description resume])
  end
end

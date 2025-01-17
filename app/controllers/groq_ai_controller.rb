class GroqAiController < ApplicationController
  def create
    replacements = {
      type: params[:type],
      topic: params[:topic],
      tone: params[:tone]
    }

    prompt = PromptGenerator.generate(replacements)
    ai_response = GroqAiApiService.new(prompt).call

    if ai_response['error']
      render json: { error: ai_response['error'] }, status: :unprocessable_entity
    else
      render json: { response: ai_response }, status: :ok
    end
  end
end

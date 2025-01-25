class GenerateCoverLetterGroqAiJob
  include Sidekiq::Job
  # include Turbo::StreamsHelper

  def perform(*args)
    job_id = args[0]
    replacements = args[1]

    prompt = PromptGenerator.generate(replacements)

    service = GroqAiApiService.new(prompt)
    response = service.call

    # Extract content or handle errors
    body = if response&.[]('choices')&.[](0)&.[]('message')&.[]('content').present?
             response['choices'][0]['message']['content']
           else
             response = "Error: #{response['error']}"
           end

    cover_letter = CoverLetter.new(body:, job_id:)

    # cover_letter = CoverLetter.last
    # sleep 2

    body = if cover_letter.save
             cover_letter.body
           else
             'Error Occured'
           end

    # Broadcast the content to the turbo frame
    Turbo::StreamsChannel.broadcast_replace_to(
      'ai_response',
      target: "ai_response_for_user_#{cover_letter.job.user.id}",
      partial: 'cover_letters/cover_letter',
      locals: { cover_letter: body, user: cover_letter.job.user }
    )
  end
end

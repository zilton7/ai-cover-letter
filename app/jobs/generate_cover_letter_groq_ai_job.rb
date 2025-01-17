class GenerateCoverLetterGroqAiJob
  include Sidekiq::Job
  include Turbo::StreamsHelper

  def perform(*_args)
    # job_id = args[0]
    # replacements = args[1]

    # prompt = PromptGenerator.generate(replacements)

    # service = GroqAiApiService.new(prompt)
    # response = service.call

    # # Extract content or handle errors
    # body = response['choices'][0]['message']['content'].present? ? response['choices'][0]['message']['content'] : "Error: #{response['error']}"

    # cl = CoverLetter.where(job_id:).last
    # cl.update(body:, job_id:)

    cl = CoverLetter.find 157

    # Broadcast the content to the turbo frame
    Turbo::StreamsChannel.broadcast_replace_to(
      'ai_response',
      target: 'ai_response_for_user',
      partial: 'cover_letters/cover_letter',
      locals: { cover_letter: cl.body }
    )
  end
end

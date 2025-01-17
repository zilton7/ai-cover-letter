class GroqAiApiService
  require 'net/http'
  require 'json'

  API_ENDPOINT = Rails.application.credentials.dig(:groq, :endpoint)
  API_KEY = Rails.application.credentials.dig(:groq, :api_key)

  def initialize(prompt)
    @prompt = prompt
  end

  def call
    response = Net::HTTP.post(
      URI(API_ENDPOINT),
      { "messages": [{ "role": 'user', "content": @prompt }], "model": 'llama-3.3-70b-versatile' }.to_json,
      { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{API_KEY}" }
    )

    parse_response(response)
  end

  private

  def parse_response(response)
    JSON.parse(response.body)
  rescue JSON::ParserError
    { error: 'Invalid response format' }
  end
end

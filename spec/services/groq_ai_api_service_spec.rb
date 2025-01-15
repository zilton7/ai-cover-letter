# spec/services/ai_api_service_spec.rb
require 'rails_helper'
require 'webmock/rspec'

RSpec.describe GroqAiApiService do
  before do
    allow(Rails.application.credentials).to receive(:dig).with(:groq, :endpoint).and_return('https://mocked-endpoint.com')
    allow(Rails.application.credentials).to receive(:dig).with(:groq, :api_key).and_return('mocked_api_key')

    stub_const('GroqAiApiService::API_ENDPOINT', Rails.application.credentials.dig(:groq, :endpoint))
    stub_const('GroqAiApiService::API_KEY', Rails.application.credentials.dig(:groq, :api_key))

    # Mock the API response
    stub_request(:post, Rails.application.credentials.dig(:groq, :endpoint))
      .with(
        body: { "messages": [{ "role": 'user', "content": 'Hello AI' }], "model": 'llama-3.3-70b-versatile' }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{Rails.application.credentials.dig(:groq, :api_key)}"
        }
      )
      .to_return(
        status: 200,
        body: {
          "id": 'chatcmpl-b3dbf283-007c-4993-864a-1d502a7de1e6',
          "object": 'chat.completion',
          "created": 1_736_971_786,
          "model": 'llama-3.3-70b-versatile',
          "choices": [
            {
              "index": 0,
              "message": {
                "role": 'assistant',
                "content": 'Hello Human!'
              },
              "logprobs": 'null',
              "finish_reason": 'stop'
            }
          ],
          "usage": {
            "queue_time": 0.02840310700000001,
            "prompt_tokens": 1262,
            "prompt_time": 0.144486752,
            "completion_tokens": 424,
            "completion_time": 1.541818182,
            "total_tokens": 1686,
            "total_time": 1.686304934
          },
          "system_fingerprint": 'fp_4196e754db',
          "x_groq": {
            "id": 'req_01jhnsc6nse2t8va0e1ps2jk19'
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  it 'returns the mocked API response' do
    service = GroqAiApiService.new('Hello AI')
    response = service.call

    expect(response['choices'][0]['message']['content']).to eq('Hello Human!')
  end
end

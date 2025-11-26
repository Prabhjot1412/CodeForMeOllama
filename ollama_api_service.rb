require 'net/http'
require 'json'

class OllamaApiService
  OLLAMA_MODELS = ['qwen3-coder:30b']
  def initialize(model: OLLAMA_MODELS.first)
    @model = model
  end

  def call(prompt:)
    uri = URI.parse("http://localhost:11434/api/chat")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri.request_uri, {
      'Content-Type' => 'application/json',
    })

    body = {
      model: @model,
      messages: [
        {
          "role": "user",
          "content": prompt,
        }
      ],
      stream: false,
    }
    request.body = body.to_json
    http.read_timeout = 6000

    response = http.request(request)

    response_json = JSON.parse(response.body)
    return response_json['message']['content']
  end
end

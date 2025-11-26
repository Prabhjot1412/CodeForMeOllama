# invoke with ruby CodeForMeOllama path/to/file

require_relative 'ollama_api_service'
require 'debug'

file = File.read(ARGV[0])
file_lines = file.lines

ollama_api_service = OllamaApiService.new

prompt = <<~PROMPT
  The following is a Ruby on Rails code file named "#{ARGV[0]}".
  Look for the comment line "# CodeForMeOllama: <instruction>" and "# CodeForMeOllama: end".
  Follow the instruction to modify the code inside the section.
  Only provide the modified code for the section, do not include any explanations or extra text.
    Here is the content of the file:

    #{file}

    Please provide the modified code for the section only.
PROMPT

response = ollama_api_service.call(prompt: prompt)
response.gsub!(/\A```ruby/, '')
response.gsub!(/```+\z/, '')

start_index = 0
end_index = 0
file_lines.each_with_index do |line, index|
  if line.strip.start_with?('# CodeForMeOllama:')
    instruction = line.strip.sub('# CodeForMeOllama:', '').strip
    if instruction != 'end'
      start_index = index
    else
      end_index = index
    end

    file_lines[index] = ''
  end
end
file_lines[(start_index + 1)...end_index] = response.lines

File.open(ARGV[0], 'w') do |f|
  f.write(file_lines.join)
end

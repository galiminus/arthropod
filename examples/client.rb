require 'arthropod'

loop do
  text = gets
  break if text.strip == "quit"

  response = Arthropod::Client.push(queue_name: "my_little_queue", payload: { text: text }) do |response|
    puts "Downcase: #{response.payload}"
  end
  puts "Upcase: #{response.payload}"
end

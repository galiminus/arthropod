require 'arthropod'

loop do
  text = gets
  break if text.strip == "quit"

  response = Arthropod::Client.push(queue_name: "my_little_queue", body: { text: text }) do |response|
    puts "Downcase: #{response.body}"
  end
  puts "Upcase: #{response.body}"
end

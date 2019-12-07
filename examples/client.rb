require 'arthropod'

loop do
  response = Arthropod::Client.push(queue_name: "my_little_queue", body: { text: gets }) do |response|
    puts "Downcase: #{response.body}"
  end
  puts "Upcase: #{response.body}"
end

require 'arthropod'

loop do
  Arthropod::Server.pull(queue_name: "my_little_queue") do |request|
    request.respond request.body["text"].downcase

    request.body["text"].upcase
  end
end

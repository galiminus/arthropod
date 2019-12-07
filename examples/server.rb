require 'arthropod'

loop do
  Arthropod::Server.pull(queue_name: "my_little_queue") do |request|
    request.respond request.payload["text"].downcase

    request.payload["text"].upcase
  end
end

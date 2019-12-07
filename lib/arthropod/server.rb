require 'aws-sdk-sqs'

module Arthropod
  module Server
    def self.pull(queue_name:, client: nil)
      client ||= Aws::SQS::Client.new

      sender_queue = client.create_queue(queue_name: queue_name)
      response = client.receive_message(queue_url: sender_queue.queue_url, max_number_of_messages: 1, wait_time_seconds: 1)
      response.messages.each do |message|
        request = Arthropod::Request.new(client: client, message: message)
        begin
          request.close(yield request)
        ensure
          client.delete_message(queue_url: sender_queue.queue_url, receipt_handle: message.receipt_handle)
        end
      end
    end
  end
end

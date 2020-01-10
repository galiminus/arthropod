require 'aws-sdk-sqs'
require 'securerandom'

module Arthropod
  module Client
    class ServerError < StandardError; end

    def self.push(queue_name:, body:, client: nil)
      client ||= Aws::SQS::Client.new

      sender_queue = client.create_queue(queue_name: queue_name)
      return_queue = client.create_queue(queue_name: SecureRandom.uuid.gsub("-", "_"))

      # Send our order with a return queue so we can get responses
      client.send_message(queue_url: sender_queue.queue_url, message_body: JSON.dump({ return_queue_url: return_queue.queue_url, body: body }))

      loop do
        response = client.receive_message(queue_url: return_queue.queue_url, max_number_of_messages: 1, wait_time_seconds: 20)
        response.messages.each do |message|
          response = Arthropod::Response.new(client: client, message: message)
          begin
            if response.state == "close"
              return response
            elsif response.state == "error"
              raise Arthropod::Client::ServerError
            else
              yield response if block_given?
            end
          ensure
            client.delete_message(queue_url: return_queue.queue_url, receipt_handle: message.receipt_handle)
          end
        end
      end
    ensure
      client.delete_queue(queue_url: return_queue.queue_url) if return_queue
    end
  end
end
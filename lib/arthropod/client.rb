require 'aws-sdk-sqs'
require 'securerandom'

module Arthropod
  module Client
    def self.configure(access_key_id:, secret_access_key:, region:)
      @access_key_id = access_key_id
      @secret_access_key = secret_access_key
      @region = region
    end

    def self.push(queue_name:, payload:, access_key_id: nil, secret_access_key: nil, region: nil, client: nil, timeout: nil)
      client ||= Aws::SQS::Client.new({
        access_key_id: access_key_id || self.access_key_id,
        secret_access_key: secret_access_key || self.secret_access_key,
        region: region || self.region
      })

      return_queue = self.push_message(queue_name: queue_name, client: client, payload: payload)

      loop do
        response = client.receive_message(queue_url: return_queue.queue_url, max_number_of_messages: 1, wait_time_seconds: 1)
        response.messages.each do |message|
          yield message
        end
      end
    ensure
      client.delete_queue queue_url: return_queue.queue_url
    end

    def self.push_message(queue_name:, client:, payload:)
      client.create_queue(queue_name: SecureRandom.uuid.gsub("-", "_")).tap do |return_queue|
        sender_queue = client.create_queue(queue_name: queue_name)
        client.send_message(queue_url: sender_queue.queue_url, message_body: JSON.dump({ return_queue_url: return_queue.queue_url, payload: payload }))
      end
    end

    def self.access_key_id
      @access_key_id || ENV["AWS_ACCESS_KEY_ID"]
    end

    def self.secret_access_key
      @secret_access_key || ENV["AWS_SECRET_ACCESS_KEY"]
    end

    def self.region
      @region || ENV["AWS_REGION"]
    end
  end
end
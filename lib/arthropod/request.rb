require 'digest'

module Arthropod
  class Request
    attr_reader :message, :client, :message_group_id

    def initialize(client:, message:)
      @client = client
      @message = message
      @message_group_id = Digest::SHA1.hexdigest(return_queue_url)
      @sequence = 0
    end

    def body
      parsed_message_body["body"]
    end

    def return_queue_url
      parsed_message_body["return_queue_url"]
    end

    def state
      parsed_message_body["state"]
    end

    def respond(body = nil)
      send_message({ state: "open", body: body })
    end

    def close!(body = nil)
      send_message({ state: "close", body: body })
    end

    def error!(body = nil)
      send_message({ state: "error", body: body })
    end

    private

    def send_message(message_body)
      client.send_message({
        queue_url: return_queue_url,
        message_body: JSON.dump(message_body),
        message_group_id: message_group_id,
        message_deduplication_id: message_deduplication_id
      })
    end

    def message_deduplication_id
      "sequence:#{@sequence += 1}"
    end

    def parsed_message_body
      @parsed_message_body ||= JSON.parse(message.body)
    end
  end
end
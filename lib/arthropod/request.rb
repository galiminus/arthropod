module Arthropod
  class Request
    attr_reader :message, :client

    def initialize(client:, message:)
      @client = client
      @message = message
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

    def close(body = nil)
      send_message({ state: "close", body: body })
    end

    private

    def send_message(message_body)
      client.send_message({
        queue_url: return_queue_url,
        message_body: JSON.dump(message_body)
      })
    end

    def parsed_message_body
      @parsed_message_body ||= JSON.parse(message.body)
    end
  end
end
module Arthropod
  class Request
    attr_reader :message, :client

    def initialize(client:, message:)
      @client = client
      @message = message
    end

    def payload
      body["payload"]
    end

    def return_queue_url
      body["return_queue_url"]
    end

    def state
      body["state"]
    end

    def respond(payload = nil)
      send_message({ state: "open", payload: payload })
    end

    def close(payload = nil)
      send_message({ state: "close", payload: payload })
    end

    private

    def send_message(message_body)
      client.send_message({
        queue_url: return_queue_url,
        message_body: JSON.dump(message_body)
      })
    end

    def body
      @body ||= JSON.parse(message.body)
    end
  end
end
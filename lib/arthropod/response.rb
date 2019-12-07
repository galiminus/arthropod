module Arthropod
  class Response
    attr_reader :message, :client

    def initialize(client:, message:)
      @client = client
      @message = message
    end

    def body
      parsed_message_body["body"]
    end

    def state
      parsed_message_body["state"]
    end

    private

    def parsed_message_body
      @parsed_message_body ||= JSON.parse(message.body)
    end
  end
end
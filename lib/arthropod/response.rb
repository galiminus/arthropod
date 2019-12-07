module Arthropod
  class Response
    attr_reader :message, :client

    def initialize(client:, message:)
      @client = client
      @message = message
    end

    def payload
      body["payload"]
    end

    def state
      body["state"]
    end

    private

    def body
      @body ||= JSON.parse(message.body)
    end
  end
end
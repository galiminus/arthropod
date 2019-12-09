require 'arthropod'

RSpec.describe(Arthropod::Server) do
  context "#pull" do
    let(:client) do
      Aws::SQS::Client.new(stub_responses: true)
    end

    let(:sender_queue_url) do
      "https://aws.com/sender_queue_url"
    end

    let(:return_queue_url) do
      "https://aws.com/return_queue_url"
    end

    let(:uuid) do
      "444444444444-4444-4444-8888-88888888"
    end

    before(:each) do
      expect(client).to(
        receive(:create_queue)
          .with({ queue_name: "test" })
          .and_return(OpenStruct.new(queue_url: sender_queue_url))
      )
      expect(client).to(
        receive(:receive_message)
        .with({ queue_url: sender_queue_url, max_number_of_messages: 1, wait_time_seconds: 1 })
        .and_return(OpenStruct.new(messages: [ OpenStruct.new({ "body" => JSON.dump({ "body" => "request", "return_queue_url" => return_queue_url }), receipt_handle: "receipt_handle" }) ]))
      )
    end

    it "works" do
      expect(client).to(
        receive(:send_message)
        .with({ queue_url: return_queue_url, message_body: JSON.dump({ state: "open", body: "response" }) })
      )
      expect(client).to(
        receive(:send_message)
        .with({ queue_url: return_queue_url, message_body: JSON.dump({ state: "close", body: "final_response" }) })
      )

      Arthropod::Server.pull(client: client, queue_name: "test") do |request|
        expect(request.body).to eq("request")
        request.respond "response"

        "final_response"
      end
    end

    it "send error on exception" do
      expect(client).to(
        receive(:send_message)
        .with({ queue_url: return_queue_url, message_body: JSON.dump({ state: "error", body: nil }) })
      )

      expect do
        Arthropod::Server.pull(client: client, queue_name: "test") do |request|
          raise "error"
        end
      end.to raise_error(Exception)
    end
  end
end
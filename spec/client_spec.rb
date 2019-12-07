require 'arthropod'

RSpec.describe(Arthropod::Client) do
  context "#configure" do
    before(:each) do
      ENV["AWS_ACCESS_KEY_ID"] = "my_access_key_id"
      ENV["AWS_SECRET_ACCESS_KEY"] = "my_secret_access_key"
      ENV["AWS_REGION"] = "my_region"
    end

    after(:each) do
      ENV.delete "AWS_ACCESS_KEY_ID"
      ENV.delete "AWS_SECRET_ACCESS_KEY"
      ENV.delete "AWS_REGION"
    end

    it "should take credentials from environment" do
      expect(Arthropod::Client.access_key_id).to eq("my_access_key_id")
      expect(Arthropod::Client.secret_access_key).to eq("my_secret_access_key")
      expect(Arthropod::Client.region).to eq("my_region")
    end

    it "can take credentials from #configure" do
      Arthropod::Client.configure({
        access_key_id: "custom_access_key_id",
        secret_access_key: "custom_secret_access_key",
        region: "custom_region",
      })
      expect(Arthropod::Client.access_key_id).to eq("custom_access_key_id")
      expect(Arthropod::Client.secret_access_key).to eq("custom_secret_access_key")
      expect(Arthropod::Client.region).to eq("custom_region")
    end
  end

  context "#push" do
    before(:each) do
      Arthropod::Client.configure({
        access_key_id: "custom_access_key_id",
        secret_access_key: "custom_secret_access_key",
        region: "custom_region",
      })
    end

    after(:each) do
      Arthropod::Client.configure({
        access_key_id: nil,
        secret_access_key: nil,
        region: nil
      })
    end

    let(:client) do
      Aws::SQS::Client.new(stub_responses: true)
    end

    let(:sender_queue_url) do
      "https://aws.com/sender_queue_url"
    end

    let(:return_queue_url) do
      "https://aws.com/return_queue_url"
    end

    let(:payload) do
      { my_key: "my_value" }
    end

    let(:uuid) do
      "444444444444-4444-4444-8888-88888888"
    end

    it "works" do
      expect(SecureRandom).to(
        receive(:uuid)
          .and_return(uuid)
      )
      expect(client).to(
        receive(:create_queue)
          .with({ queue_name: "test" })
          .and_return(OpenStruct.new(queue_url: sender_queue_url))
      )
      expect(client).to(
        receive(:create_queue)
          .with({ queue_name: uuid.gsub("-", "_") })
          .and_return(OpenStruct.new(queue_url: return_queue_url))
      )
      expect(client).to(
        receive(:send_message)
        .with({ queue_url: sender_queue_url, message_body: JSON.dump({ return_queue_url: return_queue_url, payload: payload }) })
      )
      expect(client).to(
        receive(:receive_message)
        .with({ queue_url: return_queue_url, max_number_of_messages: 1, wait_time_seconds: 1 })
        .and_return(OpenStruct.new(messages: [{ "state" => "completed" }]))
      )
      expect(client).to(
        receive(:delete_queue)
        .with({ queue_url: return_queue_url })
      )

      Arthropod::Client.push(client: client, queue_name: "test", payload: payload) do |message|
        if message["state"] == "completed"
          break
        end
      end
    end
  end
end
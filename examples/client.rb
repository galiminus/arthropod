require 'arthropod'

source = "https://oceanwide-4579.kxcdn.com/uploads/media-dynamic/cache/jpg_optimize/uploads/media/default/0001/16/thumb_15073_default_1600.jpeg"

Arthropod::Client.push(queue_name: "my_little_queue", payload: { source: source }) do |message|
  if message["state"] == "completed"
    break
  end
end

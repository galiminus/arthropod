# Arthropod

Arthropod is a easy way to run remote ruby code synchronously, using Amazon SQS.

*Do not use it yet, the API isn't stable at all*

## Usage

A simple use case first, let's say you want to push a video encoding task to another server:

```ruby
url_of_the_video = "https://my_storage.my_service.com/my_video_file.mp4"
response = Arthropod::Client.push(queue_name: "video_encoding", body: { url: url_of_the_video })

puts response.body
# => "https://my_storage.my_service.com/my_reencoded_video_file.mp4"
```

On the "server" side:

```ruby
  Arthropod::Server.pull(queue_name: "video_encoding") do |request|
    video_url = request.body.url

    # Do the encoding stuff
    encoded_video_url = VideoEncoder.encode(video_url)

    encoded_video_url # Everything evaluated here will be sent to the client
  end
```

As you see, it's all synchronous, and since SQS will save your message until they are consumed your server doesn't even have to be listening right when you push the task(more on that later).

It is also possible to push updates from the server:

```ruby
  Arthropod::Server.pull(queue_name: "video_encoding") do |request|
    video_url = request.body.url

    # Do the encoding stuff but this time the VideoEncoder class will give you a percentage of completion
    VideoEncoder.encode(video_url) do |percentage_of_completion|
      request.respond { percentage_of_completion: percentage_of_completion }
    end

    encoded_video_url # Everything evaluated here will be sent to the client
  end
```

And on the client side:

```ruby
url_of_the_video = "https://my_storage.my_service.com/my_video_file.mp4"
response = Arthropod::Client.push(queue_name: "video_encoding", body: { url: url_of_the_video }) do |response|
  puts response.body.percentage_of_completion # => 10, 20, 30, etc
end

puts response.body
# => "https://my_storage.my_service.com/my_reencoded_video_file.mp4"
```

## Why would you do take an asynchronous thing and make synchronous?

This library is here to solve a few real use-cases we encoutered, most of them involves running heavy tasks on remote servers or on remote computers that are not accessible through the internet. For example:

* running some CUDA-related stuff from a cheap server, sometimes it's way cheaper to have a pretty beefy computers in house and run your heavy tasks on them instead of renting one for several hundred dollars each month.
* sometimes you need to access some data that are only accessible locally, thing about 3D rendering where your assets, cache, etc are all stored locally for better performance. Now your local computer can pull tasks from the SQS queue, run them and push the results.

Of course you can also achieve that by simply using SQS or any kind of message system, what Arthropod does is just to make it easier, however it's your responsibilty to run it in an asynchronous environment, think about an ActiveJob task for example. At its core Arthropod is just a thin layer around SQS.


# Arthropod

Arthropod is a easy way to run remote ruby code synchronously, using Amazon SQS.

## Why would you do take an asynchronous thing and make synchronous?

This library is here to solve a few real use-cases we encoutered, most of them involves running heavy tasks on remote servers or on remote computers that are not accessible through the internet. For example:

* running some CUDA-related stuff from a cheap server, sometimes it's way cheaper to have a pretty beefy computers in house and run your heavy tasks on them instead of renting one for several hundred dollars each month.
* sometimes you need to access some data that are only accessible locally, thing about 3D rendering where your assets, cache, etc are all stored locally for better performance. Now your local computer can pull tasks from the SQS queue, run them and push the results.

Of course you can also achieve that by simply using SQS or any kind of message system, what Arthropod does is just to make it easier, however it's your responsibilty to run it in an asynchronous environment, think about an ActiveJob task for example. At its core Arthropod is just a thin layer around SQS.


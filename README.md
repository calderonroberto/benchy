# Benchy

## Files

* **benchy.rb** The main library using resttest.bench.co, and what you came here for.
* **appmain.rb** A simple Sinatra application with benchy's API.
* **public** Where the front-end lives. Not much to see here.
* **benchy_rspec.rb** Because what's the point of life without tests.
* **config.ru** Script to run the app from Passenger.

## Live App

You can visit the Benchy app at [http://robertocalderon.ca/benchy](http://robertocalderon.ca/benchy)

![Image](https://raw.githubusercontent.com/calderonroberto/benchy/master/screenshot.gif)

## Dependencies

* sinatra 1.4.*
* rspec 3.3.*
* ruby 2.2.*

Install your dependencies via:

```
gem install sinatra rspec
```

## Getting Benched

Benchy is a Sinatra app you can run it by issuing:

```
ruby appmain.rb
```

And visiting http://localhost:4567/

## Running Tests

Run the tests using:

```
rspec benchy_rspec.rb
```

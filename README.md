# Highline::Test

A micro framework to help you test your HighLine applications.

HighLine allows you to supply your own input and output streams (instead of the
default STDIN and STDOUT). This fact facilitates testing, allowing you to use
StringIO objects for input and output.

The problem with this approach is that it is hard to seperate the test, which pushes
data to the input stream, and the application, which reads that data.

HighLine::Test resolves this problem by forking the test process.
One fork runs the tests, the other runs the application.
The two processes communicate via pipes.

HighLine::test can be used with any testing framework, e.g.

* RSpec
* Test::Unit
* Cucumber

## Installation

Add this line to your application's Gemfile:

    gem 'highline-test'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install highline-test

## Usage

```ruby
require 'highline/test'

before do
  # Before running a test, create a HighLine::Test::Client
  @client = HighLine::Test::Client.new

  # The application itself is started in a block passed to the #run method
  @client.run do |driver|
    # This block is run in a child process

    # The HighLine instance used by the application *must* be the one supplied by
    # the client.
    HighLine.stub(:new).and_return(@client.high_line)

    # Do any other setup (e.g. stubbing) here

    # Start the application under test
    MyApp.new.run

    # If this block ever completes, the child process will be killed by
    # HighLine::Test
  end
end

after do
  # Ensure the child process is cleaned up
  @client.cleanup
end

it 'says Hello' do
  # Send text input to the application
  @client.type 'Fred'

  # Test application output
  expect(@client.output).to include('Hello Fred!')
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


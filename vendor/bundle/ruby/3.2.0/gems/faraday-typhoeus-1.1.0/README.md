# Faraday Typhoeus Adapter

This is a [Faraday 2][faraday] adapter for the [Typhoeus][typhoeus] parallel HTTP client. It supports parallel HTTP requests and streaming.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'faraday-typhoeus'
```

And then execute:

    $ bundle install

Or install it yourself with `gem install faraday-typhoeus` and require it in your ruby code with `require 'faraday/typhoeus'`

## Usage

### Basic

```ruby
conn = Faraday.new(...) do |f|
  f.adapter :typhoeus
end
```

### Typhoeus Options

You can also include options for [Typhoeus][typhoeus_options]/[Ethon][ethon_options] that will be used in every request:

Note that block-style configuration for the adapter is not currently supported.

```ruby
conn = Faraday.new(...) do |f|
  f.adapter :typhoeus, forbid_reuse: true, maxredirs: 1
end
```

### Parallel Requests

The adapter supports Typhoeus's parallel request functionality:

```ruby
conn = Faraday.new(...) do |f|
  f.request  :url_encoded
  f.response :logger
  f.adapter  :typhoeus
end

responses = []

conn.in_parallel do
  # responses[0].body will be null here since the requests have not been 
  # completed
  responses = [
    conn.get('/first'), 
    conn.get('/second'),
  ]
end

# after it has been completed the response information is fully available in
# response[0].status, etc
responses[0].body
responses[1].body
```

### Streaming Responses

The adapter supports [streamed responses](faraday_streaming) via the `on_data` option:

```ruby
conn = Faraday.new(...) do |f|
  f.adapter :typhoeus
end

# Streaming

chunks = []

conn.get('/stream') do |req|
  req.options.on_data proc do |chunk, received_bytes|
    chunks << chunk
  end
end

body = chunks.join

# Server-Sent Event Polling

body = nil

begin
  conn.get('/events') do |req|
    req.options.timeout = 30

    req.options.on_data = proc do |chunk|
      # stop listening once we get some data (YMMV)
      if chunk.start_with?('data: ')
        body = chunk
        :abort # abort the request, we're done
      end
    end
  end
rescue Faraday::ConnectionFailed => ex
  raise ex unless body
end
```

## Resources

- See [Typhoeus Documentation][typhoeus] for more info.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](rubygems).

### TODO

- [ ] Better tests for parallel functionality (can port them over from Typhoeus)
- [ ] Support block-based configuration like other adapters
- [ ] Refactor the adapter a bit to look more like other Faraday 2 adapters (use `connection` etc.)
- [x] Compression support
- [x] Reason-phrase parsing support

## Contributing

Bug reports and pull requests are welcome on [GitHub][repo].

## License

The gem is available as open source under the terms of the [license][license].


[faraday]: https://github.com/lostisland/faraday
[typhoeus]: https://github.com/typhoeus/typhoeus
[typhoeus_options]: https://github.com/typhoeus/typhoeus/blob/3544111b76b95d13da7cc6bfe4eb07921d771d93/lib/typhoeus/easy_factory.rb#L13-L39
[ethon_options]: https://github.com/typhoeus/ethon/blob/5d9ddf8f609a6be4b5c60d55e1e338eeeb08f25f/lib/ethon/curls/options.rb#L214-L499
[faraday_streaming]: https://lostisland.github.io/faraday/usage/streaming
[repo]: https://github.com/dleavitt/faraday-typhoeus
[license]: LICENSE.md
[rubygems]: https://github.com/dleavitt/faraday-typhoeus/blob/main/rubygems

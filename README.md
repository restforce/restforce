# Restforce

Restforce is a ruby gem for the [Salesforce REST api](http://www.salesforce.com/us/developer/docs/api_rest/index.htm).
It's meant to be a lighter weight alternative to the [databasedotcom gem](https://github.com/heroku/databasedotcom).

It attempts to solve a couple of key issues that the databasedotcom gem has been unable to solve:

* Support for interacting with multiple users from different orgs.
* Support for parent-to-child relationships.
* Support for aggregate queries.
* Remove the need to materialize constants.
* Support for the Streaming API

## Installation

Add this line to your application's Gemfile:

    gem 'restforce

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install restforce

## Usage

### Initialization

```ruby
# If you're obtaining an oauth token from something like omniauth...
client = Restforce::Client.new :oauth_token => 'oauth token',
  :refresh_token => 'refresh token',
  :instance_url => 'instance url',
  :client_id => ENV['SALESFORCE_CLIENT_ID'],
  :client_secret => ENV['SALESFORCE_CLIENT_SECRET']

# If you're using a username and password...
client = Restforce::Client.new :username => 'foo',
  :password => 'bar',
  :client_id => ENV['SALESFORCE_CLIENT_ID'],
  :client_secret => ENV['SALESFORCE_CLIENT_SECRET']
```

### Querying

```ruby
records = client.query("select Id, Something__c from Lead where Id = 'someid'")
# => #<Restforce::Collection >

record = records.first
# => #<Restforce::SObject @type="Lead" >

record.Id
# => "someid"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

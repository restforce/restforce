# Restforce

Restforce is a ruby gem for the [Salesforce REST api](http://www.salesforce.com/us/developer/docs/api_rest/index.htm).
It's meant to be a lighter weight alternative to the [databasedotcom gem](https://github.com/heroku/databasedotcom).

It attempts to solve a couple of key issues that the databasedotcom gem has been unable to solve:

* Support for interacting with multiple users from different orgs.
* Support for parent-to-child relationships.
* Support for aggregate queries.
* Remove the need to materialize constants.
* Support for the Streaming API
* A clean and modular architecture using [Faraday middleware](https://github.com/technoweenie/faraday)

## Installation

Add this line to your application's Gemfile:

    gem 'restforce

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install restforce

## Usage

### Initialization

If you have an access token and an instance url obtained through oauth:

```ruby
client = Restforce::Client.new :oauth_token => 'oauth token',
  :instance_url  => 'instance url'
```

Although the above will work, you'll probably want to take advantage of the
(re)authentication middleware by specifying a refresh token, client id and client secret:

```ruby
client = Restforce::Client.new :oauth_token => 'oauth token',
  :refresh_token => 'refresh token',
  :instance_url  => 'instance url',
  :client_id     => 'client_id',
  :client_secret => 'client_secret'
```

If you prefer to use a username and password to authenticate:

```ruby
client = Restforce::Client.new :username => 'foo',
  :password      => 'bar',
  :client_id     => 'client_id',
  :client_secret => 'client_secret'
```

### Query

```ruby
records = client.query("select Id, Something__c from Lead where Id = 'someid'")
# => #<Restforce::Collection >

record = records.first
# => #<Restforce::SObject @type="Lead" >

record.Id
# => "someid"
```

## Search

```ruby
records = client.search('SOSL Expression')
```

## Create

```ruby
record = client.create('Account', :Name => 'Foobar Inc.')
```

## Update

```ruby
record = client.update('Account', :Id => '0016000000MRatd', :Name => 'Foobar Inc.')
```

## Destroy

```ruby
record = client.destroy('Account', '0016000000MRatd')
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

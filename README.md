# Restforce [![travis-ci](https://secure.travis-ci.org/ejholmes/restforce.png)](https://secure.travis-ci.org/ejholmes/restforce) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/ejholmes/restforce)

Restforce is a ruby gem for the [Salesforce REST api](http://www.salesforce.com/us/developer/docs/api_rest/index.htm).
It's meant to be a lighter weight alternative to the [databasedotcom gem](https://github.com/heroku/databasedotcom).

It attempts to solve a couple of key issues that the databasedotcom gem has been unable to solve:

* Support for interacting with multiple users from different orgs.
* Support for parent-to-child relationships.
* Support for aggregate queries.
* Remove the need to materialize constants.
* Support for the Streaming API
* Support for blob data types.
* A clean and modular architecture using [Faraday middleware](https://github.com/technoweenie/faraday)

## Installation

Add this line to your application's Gemfile:

    gem 'restforce'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install restforce

## Usage

Restforce is designed with flexibility and ease of use in mind. By default, all api calls will
return [Hashie::Mash](https://github.com/intridea/hashie/tree/v1.2.0) objects,
so you can do things like `client.query('select Id, (select Name from Children__r) from Account').Children__r.first.Name`.

### Initialization

Which authentication method you use really depends on your use case. If you're
building an application where many users from different orgs are authenticated
through oauth and you need to interact with data in their org on their behalf,
you should use the OAuth token authentication method.

If you're using the gem to interact with a single org (maybe you're building some
salesforce integration internally?) then you should use the username/password
authentication method.

#### OAuth token authentication

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

#### Username/Password authentication

If you prefer to use a username and password to authenticate:

```ruby
client = Restforce::Client.new :username => 'foo',
  :password       => 'bar',
  :security_token => 'security token'
  :client_id      => 'client_id',
  :client_secret  => 'client_secret'
```

#### Sandbox Orgs

You can connect to sandbox orgs by specifying a host. The default host is
'login.salesforce.com':

```ruby
client = Restforce::Client.new :host => 'test.salesforce.com'
```

#### Global configuration

You can set any of the options passed into Restforce::Client.new globally:

```ruby
Restforce.configure do |config|
  config.client_id     = ENV['SALESFORCE_CLIENT_ID']
  config.client_secret = ENV['SALESFORCE_CLIENT_SECRET']
end
```

### Query

```ruby
accounts = client.query("select Id, Something__c from Account where Id = 'someid'")
# => #<Restforce::Collection >

account = records.first
# => #<Restforce::SObject >

account.Id
# => "someid"

account.Name = 'Foobar'
account.save
# => true

account.destroy
# => true
```

### Search

```ruby
# Find all occurrences of 'bar'
client.search('FIND {bar}')
# => #<Restforce::Collection >

# Find accounts match the term 'genepoint' and return the Name field
client.search('FIND {genepoint} RETURNING Account (Name)').map(&:Name)
# => ['GenePoint']
```

### Create

```ruby
# Add a new account
client.create('Account', Name: 'Foobar Inc.')
# => '0016000000MRatd'
```

### Update

```ruby
# Update the Account with Id '0016000000MRatd'
client.update('Account', Id: '0016000000MRatd', Name: 'Whizbang Corp')
# => true
```


### Upsert

```ruby
# Update the record with external ID of 12
client.upsert('Account', 'External__c', External__c: 12, Name: 'Foobar')
```

### Destroy

```ruby
# Delete the Account with Id '0016000000MRatd'
client.destroy('Account', '0016000000MRatd')
# => true
```

### File Uploads

Using the new [Blob Data](http://www.salesforce.com/us/developer/docs/api_rest/Content/dome_sobject_insert_update_blob.htm) api feature (500mb limit):

```ruby
client.create 'Document', FolderId: '00lE0000000FJ6H',
  Description: 'Document test',
  Name: 'My image',
  Body: Restforce::UploadIO.new(File.expand_path('image.jpg', __FILE__), 'image/jpeg'))
```

Using base64 encoded data (37.5mb limit):

```ruby
client.create 'Document', FolderId: '00lE0000000FJ6H',
  Description: 'Document test',
  Name: 'My image',
  Body: Base64::encode64(File.read('image.jpg'))
```

### Streaming

Restforce supports the [Streaming API](http://wiki.developerforce.com/page/Getting_Started_with_the_Force.com_Streaming_API), and makes implementing
pub/sub with Salesforce a trivial task:

```ruby
# Initialize a client with your username/password/oauth token/etc
client = Restforce::Client.new

# Force an authentication request
client.authenticate!

EM.run {
  # Assuming you've setup a PushTopic called 'AllAccounts' (See the link above.)
  client.subscribe 'AllAccounts' do |message|
    puts message.inspect
  end
}
```

Boom, you're now receiving push notifications when Accounts are
created/updated.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

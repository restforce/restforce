# Restforce

[![travis-ci](https://travis-ci.org/ejholmes/restforce.png?branch=master)](https://travis-ci.org/ejholmes/restforce) [![Code Climate](https://codeclimate.com/github/ejholmes/restforce.png)](https://codeclimate.com/github/ejholmes/restforce) [![Dependency Status](https://gemnasium.com/ejholmes/restforce.png)](https://gemnasium.com/ejholmes/restforce)
![](https://img.shields.io/gem/dt/restforce.svg)

Restforce is a ruby gem for the [Salesforce REST api](http://www.salesforce.com/us/developer/docs/api_rest/index.htm).
It's meant to be a lighter weight alternative to the [databasedotcom gem](https://github.com/heroku/databasedotcom) that offers
greater flexibility and more advanced functionality.

Features include:

* A clean and modular architecture using [Faraday middleware](https://github.com/technoweenie/faraday) and [Hashie::Mash](https://github.com/intridea/hashie/tree/v1.2.0)'d responses.
* Support for interacting with multiple users from different orgs.
* Support for parent-to-child relationships.
* Support for aggregate queries.
* Support for the [Streaming API](#streaming)
* Support for the GetUpdated API
* Support for blob data types.
* Support for GZIP compression.
* Support for [custom Apex REST endpoints](#custom-apex-rest-endpoints).
* Support for dependent picklists.
* Support for decoding [Force.com Canvas](http://www.salesforce.com/us/developer/docs/platform_connectpre/canvas_framework.pdf) signed requests. (NEW!)

[Official Website](http://restforce.org/) | [Documentation](http://rubydoc.info/gems/restforce/frames) | [Changelog](https://github.com/ejholmes/restforce/tree/master/CHANGELOG.md)

## Installation

Add this line to your application's Gemfile:

    gem 'restforce'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install restforce

__As of [version 2.0.0](https://github.com/ejholmes/restforce/blob/master/CHANGELOG.md#200-jun-27-2015), this gem is only compatible with Ruby 1.9.3 and later.__ To use Ruby 1.9.2 and below, you'll need to manually specify that you wish to use version 1.5.3.

## Usage

Restforce is designed with flexibility and ease of use in mind. By default, all API calls will
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

It is also important to note that the client object should not be reused across different threads, otherwise you may encounter [thread-safety issues](https://www.youtube.com/watch?v=p5zQOkyCACc).

#### OAuth token authentication

```ruby
client = Restforce.new :oauth_token => 'access_token',
  :instance_url  => 'instance url'
```

Although the above will work, you'll probably want to take advantage of the (re)authentication middleware by specifying `refresh_token`, `client_id`, `client_secret`, and `authentication_callback`:

```ruby
client = Restforce.new :oauth_token => 'access_token',
  :refresh_token           => 'refresh token',
  :instance_url            => 'instance url',
  :client_id               => 'client_id',
  :client_secret           => 'client_secret',
  :authentication_callback => Proc.new {|x| Rails.logger.debug x.to_s}
```

The middleware will use the `refresh_token` automatically to acquire a new `access_token` if the existing `access_token` is invalid.

`authentication_callback` is a proc that handles the response from Salesforce when the `refresh_token` is used to obtain a new `access_token`. This allows the `access_token` to be saved for re-use later, otherwise subsequent API calls will continue the cycle of "auth failure/issue new access_token/auth success".

The proc is passed one argument, a `Hashie::Mash` of the response from the [Salesforce API](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/intro_understanding_refresh_token_oauth.htm):

```ruby
{
    "access_token" => "00Dx0000000BV7z!AR8AQP0jITN80ESEsj5EbaZTFG0RNBaT1cyWk7T5rqoDjoNIWQ2ME_sTZzBjfmOE6zMHq6y8PIW4eWze9JksNEkWUl.Cju7m4",
       "signature" => "SSSbLO/gBhmmyNUvN18ODBDFYHzakxOMgqYtu+hDPsc=",
           "scope" => "refresh_token full",
    "instance_url" => "https://na1.salesforce.com",
              "id" => "https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P",
      "token_type" => "Bearer",
       "issued_at" => "1278448384422"
}
```

The `id` field can be used to [uniquely identify](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/intro_understanding_refresh_token_oauth.htm) the user that the `access_token` and `refresh_token` belong to.

#### Username/Password authentication

If you prefer to use a username and password to authenticate:

```ruby
client = Restforce.new :username => 'foo',
  :password       => 'bar',
  :security_token => 'security token',
  :client_id      => 'client_id',
  :client_secret  => 'client_secret'
```

You can also set the username, password, security token, client ID and client
secret in environment variables:

```bash
export SALESFORCE_USERNAME="username"
export SALESFORCE_PASSWORD="password"
export SALESFORCE_SECURITY_TOKEN="security token"
export SALESFORCE_CLIENT_ID="client id"
export SALESFORCE_CLIENT_SECRET="client secret"
```

```ruby
client = Restforce.new
```

### Proxy Support

You can specify a HTTP proxy using the `proxy_uri` option, as follows, or by setting the `SALESFORCE_PROXY_URI` environment variable:

```ruby
client = Restforce.new :username => 'foo',
  :password       => 'bar',
  :security_token => 'security token',
  :client_id      => 'client_id',
  :client_secret  => 'client_secret',
  :proxy_uri      => 'http://proxy.example.com:123'
```

You may specify a username and password for the proxy with a URL along the lines of 'http://user:password@proxy.example.com:123'.

#### Sandbox Orgs

You can connect to sandbox orgs by specifying a host. The default host is
'login.salesforce.com':

```ruby
client = Restforce.new :host => 'test.salesforce.com'
```
The host can also be set with the environment variable `SALESFORCE_HOST`.

#### Global configuration

You can set any of the options passed into `Restforce.new` globally:

```ruby
Restforce.configure do |config|
  config.client_id     = 'foo'
  config.client_secret = 'bar'
end
```

### API versions

By default, the gem defaults to using version 26.0 (Winter '13) of the Salesforce API.
Some more recent API endpoints will not be available without moving to a more recent
version - if you're trying to use a method that is unavailable with your API version,
Restforce will raise an `APIVersionError`.

You can change the `api_version` setting from the default either on a per-client basis:

```ruby
client = Restforce.new api_version: "32.0" # ...
```

or, you may set it globally for Restofrce as a whole:

```ruby
Restforce.configure do |config|
  config.api_version = "32.0"
  # ...
end
```

### Bang! methods

All the CRUD methods (`create`, `update`, `upsert`, `destroy`) have equivalent methods with
a ! at the end (`create!`, `update!`, `upsert!`, `destroy!`), which can be used if you need
to do some custom error handling. The bang methods will raise exceptions, while the
non-bang methods will return false in the event that an exception is raised. This
works similarly to ActiveRecord.

* * *

### query

```ruby
accounts = client.query("select Id, Something__c from Account where Id = 'someid'")
# => #<Restforce::Collection >

account = accounts.first
# => #<Restforce::SObject >

account.sobject_type
# => 'Account'

account.Id
# => "someid"

account.Name = 'Foobar'
account.save
# => true

account.destroy
# => true
```

### query_all

```ruby
accounts = client.query_all("select Id, Something__c from Account where isDeleted = true")
# => #<Restforce::Collection >
```

query_all allows you to include results from your query that Salesforce hides in the default "query" method.  These include soft-deleted records and archived records (e.g. Task and Event records which are usually archived automatically after they are a year old).

*Only available in [version 29.0](#api-versions) and later of the Salesforce API.*

### explain

`explain` takes the same parameters as `query` and returns a query plan in JSON format.
For the nitty-gritty details on the response meanings visit the
[Salesforce Query Explain](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_query_explain.htm) page.

```ruby
accounts = client.explain("select Id, Something__c from Account where Id = 'someid'")
# => #<Restforce::Mash >
```

*Only available in [version 30.0](#api-versions) and later of the Salesforce API.*

### find

```ruby
client.find('Account', '001D000000INjVe')
# => #<Restforce::SObject Id="001D000000INjVe" Name="Test" LastModifiedBy="005G0000002f8FHIAY" ... >

client.find('Account', '1234', 'Some_External_Id_Field__c')
# => #<Restforce::SObject Id="001D000000INjVe" Name="Test" LastModifiedBy="005G0000002f8FHIAY" ... >
```

### select

`select` allows the fetching of a specific list of fields from a single object.  It requires an `external_id` lookup, but is often much faster than an arbitrary query.

```ruby
# Select the `Id` column from a record with `Some_External_Id_Field__c` set to '001D000000INjVe'
client.select('Account', '001D000000INjVe', ["Id"], 'Some_External_Id_Field__c')
# => {"attributes" : {"type" : "Account","url" : "/services/data/v20.0/sobjects/Account/Some_External_Id_Field__c/001D000000INjVe"}, "Id" : "003F000000BGIn3"}
```

### search

```ruby
# Find all occurrences of 'bar'
client.search('FIND {bar}')
# => #<Restforce::Collection >

# Find accounts matching the term 'genepoint' and return the `Name` field
client.search('FIND {genepoint} RETURNING Account (Name)').map(&:Name)
# => ['GenePoint']
```

### create

```ruby
# Add a new account
client.create('Account', Name: 'Foobar Inc.')
# => '0016000000MRatd'
```

### update

```ruby
# Update the Account with `Id` '0016000000MRatd'
client.update('Account', Id: '0016000000MRatd', Name: 'Whizbang Corp')
# => true
```

### upsert

```ruby
# Update the record with external `External__c` external ID set to '12'
client.upsert('Account', 'External__c', External__c: 12, Name: 'Foobar')
```

### destroy

```ruby
# Delete the Account with `Id` '0016000000MRatd'
client.destroy('Account', '0016000000MRatd')
# => true
```

### describe

```ruby
# Get the global describe for all sobjects
client.describe
# => { ... }

# Get the describe for the Account object
client.describe('Account')
# => { ... }
```

### describe_layouts

```ruby
# Get layouts for an sobject type
client.describe_layouts('Account')
# => { ... }

# Get the details for a specific layout by its ID
client.describe_layouts('Account', '012E0000000RHEp')
# => { ... }
```

*Only available in [version 28.0](#api-versions) and later of the Salesforce API.*

### picklist\_values


```ruby
# Fetch picklist value for Account's `Type` field
client.picklist_values('Account', 'Type')
# => [#<Restforce::Mash label="Prospect" value="Prospect">]

# Given a custom object named Automobile__c with picklist fields
# `Model__c` and `Make__c`, where options for `Model__c` depends on the value of
# `Make__c`.
client.picklist_values('Automobile__c', 'Model__c', :valid_for => 'Honda')
# => [#<Restforce::Mash label="Civic" value="Civic">, ... ]
```

### user_info

```ruby
# Get info about the logged-in user
client.user_info
# => #<Restforce::Mash active=true display_name="Chatty Sassy" email="user@example.com" ... >
```

### limits

`limits` returns the API limits for the currently connected organization. This includes information such as **Daily API calls** and **Daily Bulk API calls**. More information can be found on the
[Salesforce Limits](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_limits.htm) page.

```ruby
# Get the current limit info
limits = client.limits
# => #<Restforce::Mash >

limits["DailyApiRequests"]
# => {"Max"=>15000, "Remaining"=>14746}
```

*Only available in [version 29.0](#api-versions) and later of the Salesforce API.*

* * *

### get_updated

Retrieves the list of individual record IDs that have been updated (added or changed) within the given timespan for the specified object

```ruby
# Get the ids of all accounts which have been updated in the last day
client.get_updated('Account', Time.local(2015,8,18), Time.local(2015,8,19))
# => { ... }
```

* * *

### authenticate!

Performs an authentication and returns the response. In general, calling this
directly shouldn't be required, since the client will handle authentication for
you automatically. This should only be used if you want to force
an authentication before using the streaming api, or you want to get some
information about the user.

```ruby
response = client.authenticate!
# => #<Restforce::Mash access_token="..." id="https://login.salesforce.com/id/00DE0000000cOGcMAM/005E0000001eM4LIAU" instance_url="https://na9.salesforce.com" issued_at="1348465359751" scope="api refresh_token" signature="3fW0pC/TEY2cjK5FCBFOZdjRtCfAuEbK1U74H/eF+Ho=">

# Get the user information
info = client.get(response.id).body
info.user_id
# => '005E0000001eM4LIAU'
```

* * *

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

_See also: [Inserting or updating blob data](http://www.salesforce.com/us/developer/docs/api_rest/Content/dome_sobject_insert_update_blob.htm)_

* * *

### Downloading Attachments

Restforce also makes it incredibly easy to download Attachments:

```ruby
attachment = client.query('select Id, Name, Body from Attachment').first
File.open(attachment.Name, 'wb') { |f| f.write(attachment.Body) }
```

* * *

### Custom Apex REST endpoints

You can use Restforce to interact with your custom REST endpoints, by using
`.get`, `.put`, `.patch`, `.post`, and `.delete`.

For example, if you had the following Apex REST endpoint on Salesforce:

```apex
@RestResource(urlMapping='/FieldCase/*')
global class RESTCaseController {
  @HttpGet
  global static List<Case> getOpenCases() {
    String companyName = RestContext.request.params.get('company');
    Account company = [ Select ID, Name, Email__c, BillingState from Account where Name = :companyName];

    List<Case> cases = [SELECT Id, Subject, Status, OwnerId, Owner.Name from Case WHERE AccountId = :company.Id];
    return cases;
  }
}
```

Then you could query the cases using Restforce:

```ruby
client.get '/services/apexrest/FieldCase', :company => 'GenePoint'
# => #<Restforce::Collection ...>
```

* * *

### Streaming

Restforce supports the [Streaming API](http://wiki.developerforce.com/page/Getting_Started_with_the_Force.com_Streaming_API), and makes implementing
pub/sub with Salesforce a trivial task:

```ruby
# Restforce uses faye as the underlying implementation for CometD.
require 'faye'

# Initialize a client with your username/password/oauth token/etc.
client = Restforce.new :username => 'foo',
  :password       => 'bar',
  :security_token => 'security token'
  :client_id      => 'client_id',
  :client_secret  => 'client_secret'

# Create a PushTopic for subscribing to Account changes.
client.create! 'PushTopic', {
  ApiVersion: '23.0',
  Name: 'AllAccounts',
  Description: 'All account records',
  NotifyForOperations: 'All',
  NotifyForFields: 'All',
  Query: "select Id from Account"
}

EM.run {
  # Subscribe to the PushTopic.
  client.subscribe 'AllAccounts' do |message|
    puts message.inspect
  end
}
```

Boom, you're now receiving push notifications when Accounts are
created/updated.

_See also: [Force.com Streaming API docs](http://www.salesforce.com/us/developer/docs/api_streaming/index.htm)_

*Note:* Restforce's streaming implementation is known to be compatible with version `0.8.9` of the faye gem.

* * *

### Caching

The gem supports easy caching of GET requests (e.g. queries):

```ruby
# rails example:
client = Restforce.new cache: Rails.cache

# or
Restforce.configure do |config|
  config.cache = Rails.cache
end
```

If you enable caching, you can disable caching on a per-request basis by using
.without_caching:

```ruby
client.without_caching do
  client.query('select Id from Account')
end
```

* * *

### Logging/Debugging/Instrumenting

You can easily inspect what Restforce is sending/receiving by enabling logging, either
globally (as below) or on a per-client basis.

```ruby
Restforce.log = true

# Restforce will log to STDOUT with the `:debug` log level by default, or you can
# optionally set your own logger and log level
Restforce.configure do |config|
  config.logger = Logger.new("/tmp/log/restforce.log")
  config.log_level = :info
end

client = Restforce.new.query('select Id, Name from Account')
```

Another awesome feature about restforce is that, because it is based on
Faraday, you can insert your own middleware. For example, if you were using
Restforce in a rails app, you can setup custom reporting to
[Librato](https://github.com/librato/librato-rails) using ActiveSupport::Notifications:

```ruby
client = Restforce.new do |builder|
  builder.insert_after Restforce::Middleware::InstanceURL,
    FaradayMiddleware::Instrumentation, name: 'request.salesforce'
end

# config/initializers/notifications.rb
ActiveSupport::Notifications.subscribe('request.salesforce') do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  Librato.increment 'api.salesforce.request.total'
  Librato.timing 'api.salesforce.request.time', event.duration
end
```

## Force.com Canvas

You can use Restforce to decode signed requests from Salesforce. See [the example app](https://gist.github.com/4052312).

## Tooling API

To use the [Tooling API](http://www.salesforce.com/us/developer/docs/api_toolingpre/api_tooling.pdf),
call `Restforce.tooling` instead of `Restforce.new`:

```ruby
client = Restforce.tooling(...)
```

## Links

If you need a full Active Record experience, may be you can use
[ActiveForce](https://github.com/ionia-corporation/active_force) that wraps
Restforce and adds Associations, Query Building (like AREL), Validations and
Callbacks.

## Contributing

We welcome all contributions - they help us make Restforce the best gem possible.

See our [CONTRIBUTING.md](https://github.com/ejholmes/restforce/blob/master/CONTRIBUTING.md) file for help with getting set up to work on the project locally.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create your Pull Request

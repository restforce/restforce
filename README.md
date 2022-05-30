# Restforce

[![CircleCI](https://circleci.com/gh/restforce/restforce.svg?style=svg)](https://circleci.com/gh/restforce/restforce)
![Downloads](https://img.shields.io/gem/dt/restforce.svg)

Restforce is a ruby gem for the [Salesforce REST api](http://www.salesforce.com/us/developer/docs/api_rest/index.htm).

Features include:

* A clean and modular architecture using [Faraday middleware](https://github.com/technoweenie/faraday) and [Hashie::Mash](https://github.com/intridea/hashie/tree/v1.2.0)'d responses.
* Support for interacting with multiple users from different organizations.
* Support for parent-to-child relationships.
* Support for aggregate queries.
* Support for the [Streaming API](#streaming)
* Support for the [Composite API](#composite-api)
* Support for the [Composite Batch API](#composite-batch-api)
* Support for the GetUpdated API
* Support for blob data types.
* Support for GZIP compression.
* Support for [custom Apex REST endpoints](#custom-apex-rest-endpoints).
* Support for dependent picklists.
* Support for decoding [Force.com Canvas](http://www.salesforce.com/us/developer/docs/platform_connectpre/canvas_framework.pdf) signed requests. (NEW!)

[Official Website](https://restforce.github.io/) | [Documentation](http://rubydoc.info/gems/restforce/frames) | [Changelog](https://github.com/restforce/restforce/tree/master/CHANGELOG.md)

## Installation

Add this line to your application's Gemfile:

    gem 'restforce', '~> 5.3.0'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install restforce

__As of version 5.1.0, this gem is only compatible with Ruby 2.6.0 and later.__ If you're using an earlier Ruby version:

* for Ruby 2.5, use version 5.0.6 or earlier
* for Ruby 2.4, use version 4.3.0 or earlier
* for Ruby 2.3, use version 3.2.0 or earlier
* for Ruby versions 2.2, 2.1 and 2.0, use version 2.5.3 or earlier
* for Ruby 1.9.3, use version 2.4.2

This gem is versioned using [Semantic Versioning](http://semver.org/), so you can be confident when updating that there will not be breaking changes outside of a major version (following format MAJOR.MINOR.PATCH, so for instance moving from 3.1.0 to 4.0.0 would be allowed to include incompatible API changes). See the [changelog](https://github.com/restforce/restforce/tree/master/CHANGELOG.md) for details on what has changed in each version.

## Usage

Restforce is designed with flexibility and ease of use in mind. By default, all API calls will
return [Hashie::Mash](https://github.com/intridea/hashie/tree/v1.2.0) objects,
so you can do things like `client.query('select Id, (select Name from Children__r) from Account').first.Children__r.first.Name`.

### Initialization

Which authentication method you use really depends on your use case. If you're
building an application where many users from different organizations are authenticated
through oauth and you need to interact with data in their org on their behalf,
you should use the OAuth token authentication method.

If you're using the gem to interact with a single org (maybe you're building some
salesforce integration internally?) then you should use the username/password
authentication method.

It is also important to note that the client object should not be reused across different threads, otherwise you may encounter [thread-safety issues](https://www.youtube.com/watch?v=p5zQOkyCACc).

#### OAuth token authentication

```ruby
client = Restforce.new(oauth_token: 'access_token',
                       instance_url: 'instance url',
                       api_version: '41.0')
```

Although the above will work, you'll probably want to take advantage of the (re)authentication middleware by specifying `refresh_token`, `client_id`, `client_secret`, and `authentication_callback`:

```ruby
client = Restforce.new(oauth_token: 'access_token',
                       refresh_token: 'refresh token',
                       instance_url: 'instance url',
                       client_id: 'client_id',
                       client_secret: 'client_secret',
                       authentication_callback: Proc.new { |x| Rails.logger.debug x.to_s },
                       api_version: '41.0')
```

The middleware will use the `refresh_token` automatically to acquire a new `access_token` if the existing `access_token` is invalid. The refresh process uses the `host` option so make sure that is set correctly for sandbox organizations.

`authentication_callback` is a proc that handles the response from Salesforce when the `refresh_token` is used to obtain a new `access_token`. This allows the `access_token` to be saved for re-use later - otherwise subsequent API calls will continue the cycle of "auth failure/issue new access_token/auth success".

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
client = Restforce.new(username: 'foo',
                       password: 'bar',
                       security_token: 'security token',
                       client_id: 'client_id',
                       client_secret: 'client_secret',
                       api_version: '41.0')
```

#### JWT Bearer Token

If you prefer to use a [JWT Bearer Token](https://developer.salesforce.com/page/Digging_Deeper_into_OAuth_2.0_on_Force.com#Obtaining_an_Access_Token_using_a_JWT_Bearer_Token) to authenticate:

```ruby
client = Restforce.new(username: 'foo',
                       client_id: 'client_id',
                       instance_url: 'instance_url',
                       jwt_key: 'certificate_private_key',
                       api_version: '38.0')
```

The `jwt_key` option is the private key of the certificate uploaded to your Connected App in Salesforce.
Choose "use digital signatures" in the Connected App configuration screen to upload your certificate.

You can also set the username, password, security token, client ID, client
secret and API version in environment variables:

```bash
export SALESFORCE_USERNAME="username"
export SALESFORCE_PASSWORD="password"
export SALESFORCE_SECURITY_TOKEN="security token"
export SALESFORCE_CLIENT_ID="client id"
export SALESFORCE_CLIENT_SECRET="client secret"
export SALESFORCE_API_VERSION="41.0"
```

```ruby
client = Restforce.new
```

#### Sandbox Organizations

You can connect to sandbox organizations by specifying a host. The default host is
'login.salesforce.com':

```ruby
client = Restforce.new(host: 'test.salesforce.com')
```
The host can also be set with the environment variable `SALESFORCE_HOST`.

#### Proxy Support

You can specify a HTTP proxy using the `proxy_uri` option, as follows, or by setting the `SALESFORCE_PROXY_URI` environment variable:

```ruby
client = Restforce.new(username: 'foo',
                       password: 'bar',
                       security_token: 'security token',
                       client_id: 'client_id',
                       client_secret: 'client_secret',
                       proxy_uri: 'http://proxy.example.com:123',
                       api_version: '41.0')
```

You may specify a username and password for the proxy with a URL along the lines of 'http://user:password@proxy.example.com:123'.

#### Global configuration

You can set any of the options passed into `Restforce.new` globally:

```ruby
Restforce.configure do |config|
  config.client_id     = 'foo'
  config.client_secret = 'bar'
end
```

### API versions

By default, the gem defaults to using Version 26.0 (Winter '13) of the Salesforce API. This maintains backwards compatibility for existing users.

__We strongly suggest configuring Restforce to use the most recent API version, currently Version 41.0 (Winter '18) to get the best Salesforce API experience__ - for example, some more recently-added API endpoints will not be available without moving to a more recent
version. If you're trying to use a method that is unavailable with your API version,
Restforce will raise an `APIVersionError`.

There are three ways to set the API version:

* Passing in an `api_version` option when instantiating `Restforce` (i.e. `Restforce.new(api_version: '41.0')`)
* Setting the `SALESFORCE_API_VERSION` environment variable (i.e. `export SALESFORCE_API_VERSION="41.0"`)
* Configuring the version globally with `Restforce.configure`:

```ruby
Restforce.configure do |config|
  config.api_version = '41.0'
  # ...
end
```


### Bang! methods

All the CRUD methods (`create`, `update`, `upsert`, `destroy`) have equivalent methods with
a ! at the end (`create!`, `update!`, `upsert!`, `destroy!`), which can be used if you need
to do some custom error handling. The bang methods will raise exceptions, while the
non-bang methods will return false in the event that an exception is raised. This
works similarly to ActiveRecord.


### Custom Headers

Salesforce allows the addition of
[custom headers](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/headers.htm)
in REST API requests to trigger specific logic. In order to pass any custom headers along with API requests,
you can specify a hash of `:request_headers`  upon client initialization. The example below demonstrates how
to include the `sforce-auto-assign` header in all client HTTP requests:

```ruby
client = Restforce.new(oauth_token: 'access_token',
                       instance_url: 'instance url',
                       api_version: '41.0',
                       request_headers: { 'sforce-auto-assign' => 'FALSE' })

```

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
# => true or "RecordId"
```

The upsert method will return the record Id if included in the response body from the Salesforce API; otherwise, it returns true. Currently the Salesforce API only returns the Id for newly created records.

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
client.picklist_values('Automobile__c', 'Model__c', valid_for: 'Honda')
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

### get_deleted

Retrieves the list of IDs and time of deletion for records that have been deleted within the given timespan for the specified object

```ruby
# Get the list of accounts which have been deleted in the last day
client.get_deleted('Account', Time.local(2015,8,18), Time.local(2015,8,19))
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

Using the new [Blob Data](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_sobject_insert_update_blob.htm) api feature (500mb limit):

```ruby
client.create('Document', FolderId: '00lE0000000FJ6H',
                          Description: 'Document test',
                          Name: 'My image',
                          Body: Restforce::FilePart.new(File.expand_path('image.jpg', __FILE__), 'image/jpeg')
```

Using base64 encoded data (37.5mb limit):

```ruby
client.create('Document', FolderId: '00lE0000000FJ6H',
                          Description: 'Document test',
                          Name: 'My image',
                          Body: Base64::encode64(File.read('image.jpg'))
```

_See also: [Inserting or updating blob data](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_sobject_insert_update_blob.htm)_

* * *

### Downloading Attachments and Documents

Restforce also makes it incredibly easy to download Attachments or Documents:

##### Attachments
```ruby
attachment = client.query('select Id, Name, Body from Attachment').first
File.open(attachment.Name, 'wb') { |f| f.write(attachment.Body) }
```
##### Documents
```ruby
document = client.query('select Id, Name, Body from Document').first
File.open(document.Name, 'wb') { |f| f.write(document.Body) }
```

**Note:** The example above is only applicable if your SOQL query returns a single Document record. If more than one record is returned,
the Body field contains an URL to retrieve the BLOB content for the first 2000 records returned. Subsequent records contain the BLOB content
in the Body field. This is confusing and hard to debug. See notes in [Issue #301](https://github.com/restforce/restforce/issues/301#issuecomment-298972959) explaining this detail.
**Executive Summary:** Don't retrieve the Body field in a SOQL query; instead, use the BLOB retrieval URL documented
in [SObject BLOB Retrieve](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_sobject_blob_retrieve.htm)

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
client.get('/services/apexrest/FieldCase', company: 'GenePoint')
# => #<Restforce::Collection ...>
```

* * *

### Streaming

Restforce supports the [Streaming API](https://trailhead.salesforce.com/en/content/learn/modules/api_basics/api_basics_streaming), and makes implementing
pub/sub with Salesforce a trivial task.

Here is an example of creating and subscribing to a `PushTopic`:

```ruby
# Restforce uses faye as the underlying implementation for CometD.
require 'faye'

# Initialize a client with your username/password/oauth token/etc.
client = Restforce.new(username: 'foo',
                       password: 'bar',
                       security_token: 'security token',
                       client_id: 'client_id',
                       client_secret: 'client_secret')

# Create a PushTopic for subscribing to Account changes.
client.create!('PushTopic',
               ApiVersion: '23.0',
               Name: 'AllAccounts',
               Description: 'All account records',
               NotifyForOperations: 'All',
               NotifyForFields: 'All',
               Query: "select Id from Account")

EM.run do
  # Subscribe to the PushTopic.
  client.subscription '/topic/AllAccounts' do |message|
    puts message.inspect
  end
end
```

Boom, you're now receiving push notifications when Accounts are
created/updated.

#### Composite API

Restforce supports the [Composite API](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_composite_composite.htm).
This feature permits the user to send a composite object—that is, a complex
object with nested children—in a single API call. Up to 25 requests may be
included in a single composite.

Note that `GET` is not yet implemented for this API.

```ruby
# build up an array of requests:
requests << {
  method: :update,
  sobject: sobject, # e.g. "Contact"
  reference_id: reference_id,
  data: data
}

# send every 25 requests as a subrequest in a single composite call
requests.each_slice(25).map do |req_slice|
  client.composite do |subrequest|
    req_slice.each do |r|
      subrequest.send *r.values
    end
  end
end

# note that we're using `map` to return an array of each responses to each
# composite call; 100 requests will produce 4 responses
```

#### Composite Batch API

Restforce supports the [Composite Batch API](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_composite_batch.htm).
This feature permits up to 25 subrequests in a single request, though each
subrequest counts against the API limit. On the other hand, it has fewer
limitations than the Composite API.

```
client.batch do |subrequests|
  subrequests.create('Object', name: 'test')
  subrequests.update('Object', id: '123', name: 'test')
  subrequests.destroy('Object', '123')
end
```

#### Replaying Events

Since API version 37.0, Salesforce stores events for 24 hours and they can be
replayed if your application experienced some downtime.

In order to replay past events, all you need to do is specify the last known
event ID when subscribing and you will receive all events that happened since
that event ID:

```ruby
EM.run {
  # Subscribe to the PushTopic.
  client.subscription '/topic/AllAccounts', replay: 10 do |message|
    puts message.inspect
  end
}
```

In this specific case you will see events with replay ID 11, 12 and so on.

There are two magic values for the replay ID accepted by Salesforce:

* `-2`, for getting all the events that appeared in the last 24 hours
* `-1`, for getting only newer events

**Warning**: Only use a replay ID of a event from the last 24 hours otherwise
Salesforce will not send anything, including newer events. If in doubt, use one
of the two magic replay IDs mentioned above.

You might want to store the replay ID in some sort of datastore so you can
access it, for example between application restarts. In that case, there is the
option of passing a custom replay handler which responds to `[]` and `[]=`.

Below is a sample replay handler that stores the replay ID for each channel in
memory using a Hash, stores a timestamp and has some rudimentary logic that
will use one of the magic IDs depending on the value of the timestamp:

```ruby
class SimpleReplayHandler

  MAX_AGE = 86_400 # 24 hours

  INIT_REPLAY_ID = -1
  DEFAULT_REPLAY_ID = -2

  def initialize
    @channels = {}
    @last_modified = nil
  end

  # This method is called during the initial subscribe phase
  # in order to send the correct replay ID.
  def [](channel)
    if @last_modified.nil?
      puts "[#{channel}] No timestamp defined, sending magic replay ID #{INIT_REPLAY_ID}"

      INIT_REPLAY_ID
    elsif old_replay_id?
      puts "[#{channel}] Old timestamp, sending magic replay ID #{DEFAULT_REPLAY_ID}"

      DEFAULT_REPLAY_ID
    else
      @channels[channel]
    end
  end

  def []=(channel, replay_id)
    puts "[#{channel}] Writing replay ID: #{replay_id}"

    @last_modified = Time.now
    @channels[channel] = replay_id
  end

  def old_replay_id?
    @last_modified.is_a?(Time) && Time.now - @last_modified > MAX_AGE
  end
end
```

In order to use it, simply pass the object as the value of the `replay` option
of the subscription:

```ruby
EM.run {
  # Subscribe to the PushTopic and use the custom replay handler to store any
  # received replay ID.
  client.subscription '/topic/AllAccounts', replay: SimpleReplayHandler.new do |message|
    puts message.inspect
  end
}
```

_See also_:

* [Force.com Streaming API docs](http://www.salesforce.com/us/developer/docs/api_streaming/index.htm)
* [Message Durability docs](https://developer.salesforce.com/docs/atlas.en-us.api_streaming.meta/api_streaming/using_streaming_api_durability.htm)

*Note:* Restforce's streaming implementation is known to be compatible with version `0.8.9` of the faye gem.

* * *

### Caching

The gem supports easy caching of GET requests (e.g. queries):

```ruby
# rails example:
client = Restforce.new(cache: Rails.cache)

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

If you prefer to opt in to caching on a per-request, you can do so by using .with_caching and
setting the `use_cache` config option to false:

```ruby
Restforce.configure do |config|
  config.cache = Rails.cache
  config.use_cache = false
end
```

```ruby
client.with_caching do
  client.query('select Id from Account')
end
```

Caching is done based on your authentication credentials, so cached responses will not be shared between different Salesforce logins.

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

You can use the Tooling API to add fields to existing objects. For example, add "Twitter Username" to the default "Account" object:

```ruby
client = Restforce.tooling(...)
client.create!("CustomField", {
  "FullName" => "Account.orgnamespace__twitter_username__c",
  "Metadata" => { type: "Text", label: "Twitter Username", length: 15 },
})
```

## Links

If you need a full Active Record experience, may be you can use
[ActiveForce](https://github.com/ionia-corporation/active_force) that wraps
Restforce and adds Associations, Query Building (like AREL), Validations and
Callbacks.

## Contributing

We welcome all contributions - they help us make Restforce the best gem possible.

See our [CONTRIBUTING.md](https://github.com/restforce/restforce/blob/master/CONTRIBUTING.md) file for help with getting set up to work on the project locally.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create your Pull Request

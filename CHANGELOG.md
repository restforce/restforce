# 5.3.0 (May 30, 2022)

* Add support for Faraday v1.9.x and v1.10.0 (@magni-, @timrogers)
* Follow redirects during authentication to support Lightning URLs (e.g. `*.lightning.force.com` instead of `*.my.salesforce.com`) (@nhocki)

# 5.2.4 (Mar 16, 2022)

* Fix `Restforce::Collection#size` for Salesforce APIs that use the `size` property to return the total number of results, instead of `totalSize` (@kwong-yw)

# 5.2.3 (Jan 17, 2022)

* Add official support for Ruby 3.1 (@timrogers)
* Fix handling of responses from the Composite API (@robob27)
* Fix dependencies to correctly declare that the gem doesn't work with [faraday](https://github.com/lostisland/faraday) `v1.9.0` or later (@timrogers)

# 5.2.2 (Dec 16, 2021)

* Handle the `MALFORMED_SEARCH` error returned by Salesforce (@timrogers)

# 5.2.1 (Dec 8, 2021)

* Handle the `OPERATION_TOO_LARGE` error returned by Salesforce (@timrogers)
* Handle the `INVALID_SIGNUP_COUNTRY` error returned by Salesforce (@timrogers)

## 5.2.0 (Oct 15, 2021)

* Add support for Salesforce's Composite API and Composite Batch API (@meenie, @amacdougall)
* Improve the performance of counting numbers of query results with `Restforce::Collection#count`, avoiding unnecessary API requests (@jhass)

## 5.1.1 (Oct 13, 2021)

* Handle the `INVALID_REPLICATION_DATE` error returned by Salesforce (@michaelwnyc)
* Handle the `BIG_OBJECT_UNSUPPORTED_OPERATION` error returned by Salesforce (@remon)

## 5.1.0 (Aug 26, 2021)

* Add official support for Ruby 3.0 (@timrogers)
* Drop support for Ruby 2.5, which has reached end-of-life (@timrogers)
* Handle the `QUERY_TIMEOUT` error returned by Salesforce (@timrogers)
* Remove unnecessary development dependencies for the gem, which can just be in the project's `Gemfile` (@timrogers)

## 5.0.6 (Jun 17, 2021)

* Handle the `API_DISABLED_FOR_ORG` error returned by Salesforce (@cmac)
* Handle the `METHOD_NOT_ALLOWED` error returned by Salesforce (@timrogers)
* Handle the `APEX_ERROR` error returned by Salesforce (@timrogers)

## 5.0.5 (Feb 17, 2021)

* Handle the `CANNOT_EXECUTE_FLOW_TRIGGER` error returned by Salesforce (@almusavi, @timrogers)

## 5.0.4 (Jan 18, 2021)

* Handle the `INVALID_QUERY_LOCATOR` error returned by Salesforce
* Handle the `INVALID_OPERATION_WITH_EXPIRED_PASSWORD` error returned by Salesforce
* Handle the `FIELD_INTEGRITY_EXCEPTION` error returned by Salesforce
* Handle the `FORBIDDEN` error returned by Salesforce
* Handle the `ILLEGAL_QUERY_PARAMETER_VALUE` error returned by Salesforce
* Handle the `JSON_PARSER_ERROR` error returned by Salesforce

## 5.0.3 (Sep 8, 2020)

* Handle the undocumented `EXCEEDED_MAX_SEMIJOIN_SUBSELECTS` error returned by Salesforce (@embertel, @timrogers)

## 5.0.2 (Sep 6, 2020)

* Handle the undocumented `REQUEST_LIMIT_EXCEEDED` error returned by Salesforce (@wkirkby, @timrogers)
* Handle the undocumented `SERVER_UNAVAILABLE` error returned by Salesforce (@wkirkby, @timrogers)
* Refactor the library to be compatible with Rubocop 0.90's cops (this shouldn't introduce any noticeable changes see #569 for detailed changes) (@timrogers)

## 5.0.1 (Aug 13, 2020)

* Handle the undocumented `API_CURRENTLY_DISABLED` error returned by Salesforce (@ruipserra, @timrogers)
* Handle the undocumented `MALFORMED_QUERY` error returned by Salesforce (@scottserok, @timrogers)
* Handle the undocumented `INVALID_QUERY_FILTER_OPERATOR` error returned by Salesforce (@Dantemss, @timrogers)
* Add documentation and scripts for running the
library's tests using Docker (@ryansch)

## 5.0.0 (Jul 10, 2020)

For instructions on upgrading from Restforce 4.x to 5.x, see our ["Upgrading from Restforce 4.x to 5.x"](https://github.com/restforce/restforce/blob/master/UPGRADING.md) guide.

### Breaking changes 

* __⚠️  Define exception classes for Salesforce errors up-front instead of dynamically at runtime__, *running the risk that we might miss some errors which should be defined*. If any errors are missed, they will be added in patch versions (e.g. `5.0.1`). For more details on this change, see the ["Upgrading from Restforce 4.x to 5.x"](https://github.com/restforce/restforce/blob/master/UPGRADING.md) guide (@presidentbeef, @timrogers).
* __⚠️  Deprecate support for Ruby 2.4__, since [Ruby 2.4 reached its end-of-life](https://www.ruby-lang.org/en/news/2020/04/05/support-of-ruby-2-4-has-ended/) in April 2020 (@timrogers)
* __⚠️  Change the ancestry of `Restforce::UnauthorizedError` so it inherits from `Faraday::ClientError`, not `Restforce::Error`__. This breaking change was required to expose the response body returned by the API as part of this error - see the non-breaking changes entry below for further details (@michaldbianchi).

### Non-breaking changes

* Add support for `lostisland/faraday` v1.x, whilst maintaining support for v0.9.x (@ryansch)
* Add `#empty?` method to `Restforce::Collection`, returning whether they are any items in a collection (@bubaflub)
* Allow opting-in to caching on a per-call basis with `Restforce::Client#with_caching` (@swaincreates)
* Expose the response body from Salesforce on `Restforce::UnauthorizedError` and `Restforce::NotFoundError` (@michaeldbianchi)
* Remove the unnecessary depending on the `json` gem, which has been part of the Ruby standard library since v1.9 (@vonTronje)


## 4.2.2 (Jan 23, 2020)

* Fix `NoMethodError: undefined method '[]' for nil:NilClass` error when generating objects to return (@apurkiss)

## 4.2.1 (Dec 4, 2019)

* Handle empty response bodies returned with authentication errors (@sylvandor)
* Fix Faraday deprecation warning in newer Faraday versions (`v0.17.1` onwards) caused by inheriting from a deprecated class 

## 4.2.0 (Oct 23, 2019)

* Add support for platform events, CDC, generic events, etc. in the Streaming API (@nathanKramer)

## 4.1.0 (Oct 20, 2019)

* Add support for JWT authentication (@nathanKramer, @tagCincy)

## 4.0.0 (Oct 9, 2019)

* __Deprecate support for Ruby 2.3__, since [Ruby 2.3 reached its end-of-life](https://www.ruby-lang.org/en/news/2019/03/31/support-of-ruby-2-3-has-ended/) in March 2019. (This is the only breaking change included in this version.)

## 3.2.0 (Oct 9, 2019)

* Add support for the Batch API (@gaiottino, @teoulas)
* Return specific exceptions for errors that might be returned from Salesforce.com - instead of getting a generic `Faraday::Error::ClientError`, you might get something like a `Restforce::EntityTooLargeError` (@boblail)
* Expose the full response in exceptions' messages to make debugging easier (@boblail)
* Properly escape IDs with spaces in them when working with existing records (@pushups)

## 3.1.0 (Aug 16, 2018)

* Add support for replaying missed messages when using the Salesforce Streaming API (@andreimaxim, @drteeth, @panozzaj)

## 3.0.1 (Aug 4, 2018)

* Fix `NoMethodError` when upserting an existing record (@opti)

## 3.0.0 (Aug 2, 2018)

* __Deprecate support for Ruby 2.0, 2.1 and 2.2__, since [even Ruby 2.2 reached its end-of-life](https://www.ruby-lang.org/en/news/2018/06/20/support-of-ruby-2-2-has-ended/) in June 2018. (This is the only breaking change included in this version.)
* Fix `NoMethodError` when trying to upsert a record using a `Fixnum` as the external ID (@AlexandruCD)
* Escape record IDs passed in to the client to identify records to find, delete, etc. (@jmdx)
* Stop relying on our middleware for Gzip compression if you're using `httpclient`, since Faraday enables this automatically using `httpclient`'s built-in support (@shivanshgaur)
* Fix `get_updated` and `get_deleted` API calls by removing the erroneous leading forward slash from the path (@scottolsen)
* Fix unpacking of dependent picklist options (@parkm)

## 2.5.4 (May 15, 2019)

See the [`v2`](https://github.com/restforce/restforce/tree/v2) branch for this release.

* Escape record IDs passed in to the client to identify records to find, delete, etc. (@jmdx, @apanzerj)

## 2.5.3 (Apr 25, 2017)

* Raise an error where a custom external ID field name is supplied to `upsert` and `upsert!`, but it is missing from the provided attributes (@velveret)
* Use the Restforce client's configured SSL options for authentication requests (@jvdp)
* Fix bug where `upsert` and `upsert!` mutate the provided attributes, previously fixed in [v1.5.3](https://github.com/restforce/restforce/blob/master/CHANGELOG.md#153-jun-26-2015) (@velveret)


## 2.5.2 (Apr 3, 2017)

* Ensure `Restforce::Middleware::Logger` is the last Faraday middleware to be called so everything is properly logged (including the effects of the `Gzip` and `CustomHeaders` middlewares which were previously running after it) (@jonnymacs)
* Suppress [Hashie](https://github.com/intridea/hashie) warnings when using Hashie v3.5.0 or later (see [#295](https://github.com/restforce/restforce/pull/295) for details) (@janraasch)

## 2.5.1 (Mar 16, 2017)

* Allow setting custom headers, [required by parts of the Salesforce API](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/headers.htm), by specifiying a `:request_headers` option when instantiating the client (@moskeyombus)
* Add support for `upsert`ing using an ID (see the [Salesforce docs](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/dome_upsert.htm) for more details) (@ecbypi)
* Relax `faraday` dependency to allow upgrading to Faraday 1.0 (@tinogomes, @alexluke)

*(This should have been a minor version rather than a patch version, following format MAJOR.MINOR.PATCH, since we use [Semantic Versioning](http://semver.org/) and this adds functionality. Sorry! @timrogers)*

## 2.5.0 (Dec 7, 2016)

* __Deprecate support for Ruby 1.9__, since [official support was dropped nearly two years ago](https://www.ruby-lang.org/en/news/2014/01/10/ruby-1-9-3-will-end-on-2015/), and it's causing problems with keeping our dependencies up to date
* Securely hash Salesforce credentials used in cache keys, so they aren't stored in the clear (@atmos)

## 2.4.2 (Oct 20, 2016)

* Relax `json` dependency for users of Ruby 2.0.0 onwards to allow a much wider range of versions (@timrogers, with thanks to @ccutrer and @janraasch)

## 2.4.1 (Oct 18, 2016)

* Added support for pre-released versions of Ruby 2.4.0 by relaxing the `json` gem dependency (@timrogers, with thanks to @ccutrer)

## 2.4.0 (Jul 29, 2016)

* Added ability to download documents attached to records, behaving like attachments (@jhelbig)

## 2.3.0 (Jul 15, 2016)

* Allow the Salesforce API version to be specified with a `SALESFORCE_API_VERSION` environment variable (@jhelbig)

## 2.2.1 (Jun 6, 2016)

* Added support for `get_deleted` call (@adambird)

*(This should have been a minor version rather than a patch version, following format MAJOR.MINOR.PATCH, since we use [Semantic Versioning](http://semver.org/) and this adds functionality. Sorry! @timrogers)*

## 2.2.0 (Mar 16, 2016)

* Raise a `Faraday::Error::ClientError` for `300` responses triggered by a conflicting external ID, providing access to the response, which contains an array of the conflicting IDs (@timrogers, @michaelminter)
* Improve the consistency of `Faraday::Error::ClientError`s raised, so they all have a message with the same format (@timrogers)

## 2.1.3 (Mar 9, 2016)

* Raise a `Restforce::ServerError` when Salesforce responds with a `500` due to an internal error (@greysteil)
* Improving handling of response body in errors (@kuono)

## 2.1.2 (Nov 2, 2015)

* Always parse the JSON response before errors are raised to improve exceptions (@kouno)

## 2.1.1 (Aug 20, 2015)

* Added support for `get_updated` call (@web-connect)
* Respect Faraday adapter option in authentication middleware (@stenlarsson)

## 2.1.0 (Jun 29, 2015)

* Added support for `query_all`, `explain` and `limits` API calls (which require a newer `api_version` than the default of 26.0) (@theSteveMitchell, @zenchild)
* Added support for `recent` API call (@davebrace)
* Changed `PROXY_URI` environment variable to `SALESFORCE_PROXY_URI` (with warning to `STDOUT` if the old variable is set) (@timrogers)
* Implemented `version_guard` in `Restforce::Concerns::API` to standardise behaviour of API calls which require a particular version of the Salesforce API (@zenchild)
* Fixed bug with construction of `Faraday::Error::ClientError` exceptions (@debussyman)
* Added support for specifying SSL options to be passed to Faraday (@jonathanrico)
* Added support for specifying a custom logger and log level (@ilyakatz)
* Improved experience for contributors to the gem with bootstrapping process (@rafalchmiel)


## 2.0.0 (Jun 27, 2015)

* Drop support for versions of Ruby earlier than 1.9.3, which were [end-of-lifed](https://www.ruby-lang.org/en/news/2014/07/01/eol-for-1-8-7-and-1-9-2/) long ago
* Take advantages of Ruby 1.9.3 syntax, and drop old Ruby 1.8 shims
* Enforce code style with [Rubocop](https://github.com/bbatsov/rubocop)

## 1.5.3 (Jun 26, 2015)

* Fixed a bug with `update!` and `upsert!` mutating provided attributes (@timrogers)
* Added note about thread safety to `README.md` (@epbarger)
* Improved documentation for `select` in `README.md` (@theSteveMitchell)
* Tweaked and improved consistency of `README.md` (@timrogers)
* Pass through blocks given to `Restforce.new` (@jxa)
* Add `#page_size` to `Restforce::Collection` (@theSteveMitchell)

## 1.5.2 (Apr 29, 2015)

*   Better autopagination performance #141 @th7

## 1.5.1 (Nov 27, 2014)

*   Looser restrictions on hashie gem #123 @zenchild

## 1.5.0 (Oct 15, 2014)

*   Upgrade faraday dependency to 0.9 #124 @zenchild

## 1.4.1 (Jun 18, 2013)

*   Fixed a bug with HTTP 413 responses #75 @patronmanager

## 1.4.0 (Jun 9, 2013)

*   Added support for the tooling API.
*   Fixed a bug with EMSynchrony adapter.
*   Added proxy support.

## 1.3.0 (Apr 6, 2013)

*   Added support for lazily traversing paginated collections #61 by @nahiluhmot.

## 1.2.0 (Mar 30, 2013)

*   Added support for proxies #60 by @wazoo.

## 1.1.0 (Mar 3, 2013)

*   Added ability to download attachments easily.

    Example

        attachment = client.query('select Id, Name, Body from Attachment').first
        File.open(attachment.Name, 'wb') { |f| f.write(attachment.Body) }

## 1.0.6 (Feb 16, 2013)

*   Added `url` method.

    Example

        # Url to a record id
        client.url('0013000000rRz')
        # => https://na1.salesforce.com/0013000000rRz

        # Url to an object that responds to `to_sparam`
        record = Struct.new(:to_sparam).new('0013000000rRz')
        client.url('0013000000rRz')
        # => https://na1.salesforce.com/0013000000rRz


## 1.0.5 (Jan 11, 2013)

*   Added `picklist_values` method.

    Example

        client.picklist_values('Account', 'Type')

        client.picklist_values('Automobile__c', 'Model__c', :valid_for => 'Honda')

*   Added CHANGELOG.md

## 1.0.4 (Jan 8, 2013)

*   `Restforce::Client#inspect` now only prints out the options and not the
    Faraday connection.

*   The Faraday adapter is now configurabled:

    Example:

        Restforce.configure do |config|
          config.adapter = :excon
        end

*   The http connection read/open timeout is now configurabled.

    Example:

        Restforce.configure do |config|
          config.timeout = 300
        end

## 1.0.3 (Jan 7, 2013)

*   Fixed typo in method call.

## 1.0.2 (Jan 7, 2013)

*   Minor cleanup.
*   Moved decoding of signed requests into it's own class.

## 1.0.1 (Dec 31, 2012)

*   `username`, `password`, `security_token`, `client_id` and `client_secret`
    options now obtain defaults from environment variables.
*   Add `head` verb.

## 1.0.0 (Dec 23, 2012)

*   Default api version changed from 24.0 to 26.0.
*   Fixed tests for streaming api to work with latest versions of faye.
*   Added .find method to obtain all fields from an sobject.

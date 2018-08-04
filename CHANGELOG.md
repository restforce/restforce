## 3.0.1 (Aug 4, 2018)

* Fix `NoMethodError` when upserting an existing record (@opti)

## 3.0.0 (Aug 2, 2018)

* __Deprecate support for Ruby 2.0, 2.1 and 2.2__, since [even Ruby 2.2 reached its end-of-life]##(https://www.ruby-lang.org/en/news/2018/06/20/support-of-ruby-2-2-has-ended/) in June 2018. (This is the only breaking change included in this version.)
* Fix `NoMethodError` when trying to upsert a record using a `Fixnum` as the external ID (@AlexandruCD)
* Escape record IDs passed in to the client to identify records to find, delete, etc. (@jmdx)
* Stop relying on our middleware for Gzip compression if you're using `httpclient`, since Faraday enables this automatically using `httpclient`'s built-in support (@shivanshgaur)
* Fix `get_updated` and `get_deleted` API calls by removing the erroneous leading forward slash from the path (@scottolsen)
* Fix unpacking of dependent picklist options (@parkm)

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

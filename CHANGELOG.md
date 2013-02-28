## HEAD

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

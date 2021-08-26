# frozen_string_literal: true

require 'erb'
require 'uri'
require 'restforce/concerns/verbs'

module Restforce
  module Concerns
    module API
      extend Restforce::Concerns::Verbs

      # Public: Helper methods for performing arbitrary actions against the API using
      # various HTTP verbs.
      #
      # Examples
      #
      #   # Perform a get request
      #   client.get '/services/data/v24.0/sobjects'
      #   client.api_get 'sobjects'
      #
      #   # Perform a post request
      #   client.post '/services/data/v24.0/sobjects/Account', { ... }
      #   client.api_post 'sobjects/Account', { ... }
      #
      #   # Perform a put request
      #   client.put '/services/data/v24.0/sobjects/Account/001D000000INjVe', { ... }
      #   client.api_put 'sobjects/Account/001D000000INjVe', { ... }
      #
      #   # Perform a delete request
      #   client.delete '/services/data/v24.0/sobjects/Account/001D000000INjVe'
      #   client.api_delete 'sobjects/Account/001D000000INjVe'
      #
      # Returns the Faraday::Response.
      define_verbs :get, :post, :put, :delete, :patch, :head

      # Public: Get info about the logged-in user.
      #
      # Examples
      #
      #   # get the email of the logged-in user
      #   client.user_info.email
      #   # => user@example.com
      #
      # Returns an Array of String names for each SObject.
      def user_info
        get(api_get.body.identity).body
      end

      # Public: Get the names of all sobjects on the org.
      #
      # Examples
      #
      #   # get the names of all sobjects on the org
      #   client.list_sobjects
      #   # => ['Account', 'Lead', ... ]
      #
      # Returns an Array of String names for each SObject.
      def list_sobjects
        describe.collect { |sobject| sobject['name'] }
      end

      # Public: Get info about limits in the connected organization
      #
      # Only available in version 29.0 and later of the Salesforce API.
      #
      # Returns an Array of String names for each SObject.
      def limits
        version_guard(29.0) { api_get("limits").body }
      end

      # Public: Gets the IDs of sobjects of type [sobject]
      # which have changed between startDateTime and endDateTime.
      #
      # Examples
      #
      #   # get changes for sobject Whizbang between yesterday and today
      #   startDate = Time.new(2002, 10, 31, 2, 2, 2, "+02:00")
      #   endDate = Time.new(2002, 11, 1, 2, 2, 2, "+02:00")
      #   client.get_updated('Whizbang', startDate, endDate)
      #
      # Returns a Restforce::Collection if Restforce.configuration.mashify is true.
      # Returns an Array of Hash for each record in the result if
      # Restforce.configuration.mashify is false.
      def get_updated(sobject, start_time, end_time)
        start_time = start_time.utc.iso8601
        end_time = end_time.utc.iso8601
        url = "sobjects/#{sobject}/updated/?start=#{start_time}&end=#{end_time}"
        api_get(url).body
      end

      # Public: Gets the IDs of sobjects of type [sobject]
      # which have been deleted between startDateTime and endDateTime.
      #
      # Examples
      #
      #   # get deleted sobject Whizbangs between yesterday and today
      #   startDate = Time.new(2002, 10, 31, 2, 2, 2, "+02:00")
      #   endDate = Time.new(2002, 11, 1, 2, 2, 2, "+02:00")
      #   client.get_deleted('Whizbang', startDate, endDate)
      #
      # Returns a Restforce::Collection if Restforce.configuration.mashify is true.
      # Returns an Array of Hash for each record in the result if
      # Restforce.configuration.mashify is false.
      def get_deleted(sobject, start_time, end_time)
        start_time = start_time.utc.iso8601
        end_time = end_time.utc.iso8601
        url = "sobjects/#{sobject}/deleted/?start=#{start_time}&end=#{end_time}"
        api_get(url).body
      end

      # Public: Returns a detailed describe result for the specified sobject
      #
      # sobject - Stringish name of the sobject (default: nil).
      #
      # Examples
      #
      #   # get the global describe for all sobjects
      #   client.describe
      #   # => { ... }
      #
      #   # get the describe for the Account object
      #   client.describe('Account')
      #   # => { ... }
      #
      # Returns the Hash representation of the describe call.
      def describe(sobject = nil)
        if sobject
          api_get("sobjects/#{sobject}/describe").body
        else
          api_get('sobjects').body['sobjects']
        end
      end

      # Public: Returns a detailed description of the Page Layout for the
      # specified sobject type, or URIs for layouts if the sobject has
      # multiple Record Types.
      #
      # Only available in version 28.0 and later of the Salesforce API.
      #
      # Examples:
      #  # get the layouts for the sobject
      #  client.describe_layouts('Account')
      #  # => { ... }
      #
      #  # get the layout for the specified Id for the sobject
      #  client.describe_layouts('Account', '012E0000000RHEp')
      #  # => { ... }
      #
      # Returns the Hash representation of the describe_layouts result
      def describe_layouts(sobject, layout_id = nil)
        version_guard(28.0) do
          if layout_id
            api_get("sobjects/#{sobject}/describe/layouts/#{CGI.escape(layout_id)}").body
          else
            api_get("sobjects/#{sobject}/describe/layouts").body
          end
        end
      end

      # Public: Get the current organization's Id.
      #
      # Examples
      #
      #   client.org_id
      #   # => '00Dx0000000BV7z'
      #
      # Returns the String organization Id
      def org_id
        query('select id from Organization').first['Id']
      end

      # Public: Executs a SOQL query and returns the result.
      #
      # soql - A SOQL expression.
      #
      # Examples
      #
      #   # Find the names of all Accounts
      #   client.query('select Name from Account').map(&:Name)
      #   # => ['Foo Bar Inc.', 'Whizbang Corp']
      #
      # Returns a Restforce::Collection if Restforce.configuration.mashify is true.
      # Returns an Array of Hash for each record in the result if
      # Restforce.configuration.mashify is false.
      def query(soql)
        response = api_get 'query', q: soql
        mashify? ? response.body : response.body['records']
      end

      # Public: Explain a SOQL query execution plan.
      #
      # Only available in version 30.0 and later of the Salesforce API.
      #
      # soql - A SOQL expression.
      #
      # Examples
      #
      #   # Find the names of all Accounts
      #   client.explain('select Name from Account')
      #
      # Returns a Hash in the form {:plans => [Array of plan data]}
      # See: https://www.salesforce.com/us/developer/docs/api_rest/Content/dome_query_expl
      #      ain.htm
      def explain(soql)
        version_guard(30.0) { api_get("query", explain: soql).body }
      end

      # Public: Executes a SOQL query and returns the result.  Unlike the Query resource,
      # QueryAll will return records that have been deleted because of a merge or delete.
      # QueryAll will also return information about archived Task and Event records.
      #
      # Only available in version 29.0 and later of the Salesforce API.
      #
      # soql - A SOQL expression.
      #
      # Examples
      #
      #   # Find the names of all Accounts
      #   client.query_all('select Name from Account').map(&:Name)
      #   # => ['Foo Bar Inc.', 'Whizbang Corp']
      #
      # Returns a Restforce::Collection if Restforce.configuration.mashify is true.
      # Returns an Array of Hash for each record in the result if
      # Restforce.configuration.mashify is false.
      def query_all(soql)
        version_guard(29.0) do
          response = api_get 'queryAll', q: soql
          mashify? ? response.body : response.body['records']
        end
      end

      # Public: Perform a SOSL search
      #
      # sosl - A SOSL expression.
      #
      # Examples
      #
      #   # Find all occurrences of 'bar'
      #   client.search('FIND {bar}')
      #   # => #<Restforce::Collection >
      #
      #   # Find accounts match the term 'genepoint' and return the Name field
      #   client.search('FIND {genepoint} RETURNING Account (Name)').map(&:Name)
      #   # => ['GenePoint']
      #
      # Returns a Restforce::Collection if Restforce.configuration.mashify is true.
      # Returns an Array of Hash for each record in the result if
      # Restforce.configuration.mashify is false.
      def search(sosl)
        api_get('search', q: sosl).body
      end

      # Public: Insert a new record.
      #
      # sobject - String name of the sobject.
      # attrs   - Hash of attributes to set on the new record.
      #
      # Examples
      #
      #   # Add a new account
      #   client.create('Account', Name: 'Foobar Inc.')
      #   # => '0016000000MRatd'
      #
      # Returns the String Id of the newly created sobject.
      # Returns false if something bad happens.
      def create(*args)
        create!(*args)
      rescue *exceptions
        false
      end
      alias insert create

      # Public: Insert a new record.
      #
      # sobject - String name of the sobject.
      # attrs   - Hash of attributes to set on the new record.
      #
      # Examples
      #
      #   # Add a new account
      #   client.create!('Account', Name: 'Foobar Inc.')
      #   # => '0016000000MRatd'
      #
      # Returns the String Id of the newly created sobject.
      # Raises exceptions if an error is returned from Salesforce.
      def create!(sobject, attrs)
        api_post("sobjects/#{sobject}", attrs).body['id']
      end
      alias insert! create!

      # Public: Update a record.
      #
      # sobject - String name of the sobject.
      # attrs   - Hash of attributes to set on the record.
      #
      # Examples
      #
      #   # Update the Account with Id '0016000000MRatd'
      #   client.update('Account', Id: '0016000000MRatd', Name: 'Whizbang Corp')
      #
      # Returns true if the sobject was successfully updated.
      # Returns false if there was an error.
      def update(*args)
        update!(*args)
      rescue *exceptions
        false
      end

      # Public: Update a record.
      #
      # sobject - String name of the sobject.
      # attrs   - Hash of attributes to set on the record.
      #
      # Examples
      #
      #   # Update the Account with Id '0016000000MRatd'
      #   client.update!('Account', Id: '0016000000MRatd', Name: 'Whizbang Corp')
      #
      # Returns true if the sobject was successfully updated.
      # Raises an exception if an error is returned from Salesforce.
      def update!(sobject, attrs)
        id = attrs.fetch(attrs.keys.find { |k, v| k.to_s.casecmp('id').zero? }, nil)
        raise ArgumentError, 'ID field missing from provided attributes' unless id

        attrs_without_id = attrs.reject { |k, v| k.to_s.casecmp("id").zero? }
        api_patch "sobjects/#{sobject}/#{CGI.escape(id)}", attrs_without_id
        true
      end

      # Public: Update or create a record based on an external ID
      #
      # sobject - The name of the sobject to created.
      # field   - The name of the external Id field to match against.
      # attrs   - Hash of attributes for the record.
      #
      # Examples
      #
      #   # Update the record with external ID of 12
      #   client.upsert('Account', 'External__c', External__c: 12, Name: 'Foobar')
      #
      # Returns true if the record was found and updated.
      # Returns the Id of the newly created record if the record was created.
      # Returns false if something bad happens (for example if the external ID matches
      # multiple resources).
      def upsert(*args)
        upsert!(*args)
      rescue *exceptions
        false
      end

      # Public: Update or create a record based on an external ID
      #
      # sobject - The name of the sobject to created.
      # field   - The name of the external Id field to match against.
      # attrs   - Hash of attributes for the record.
      #
      # Examples
      #
      #   # Update the record with external ID of 12
      #   client.upsert!('Account', 'External__c', External__c: 12, Name: 'Foobar')
      #
      # Returns true if the record was found and updated.
      # Returns the Id of the newly created record if the record was created.
      # Raises an exception if an error is returned from Salesforce, including the 300
      # error returned if the external ID provided matches multiple records (in which
      # case the conflicting IDs can be found by looking at the response on the error)
      def upsert!(sobject, field, attrs)
        attrs = attrs.dup
        external_id =
          extract_case_insensitive_string_or_symbol_key_from_hash!(attrs, field).to_s
        if field.to_s != "Id" && (external_id.nil? || external_id.strip.empty?)
          raise ArgumentError, 'Specified external ID field missing from provided ' \
                               'attributes'
        end

        response =
          if field.to_s == "Id" && (external_id.nil? || external_id.strip.empty?)
            version_guard(37.0) do
              api_post "sobjects/#{sobject}/#{field}", attrs
            end
          else
            api_patch "sobjects/#{sobject}/#{field}/" \
                      "#{ERB::Util.url_encode(external_id)}", attrs
          end

        response.body.respond_to?(:fetch) ? response.body.fetch('id', true) : true
      end

      # Public: Delete a record.
      #
      # sobject - String name of the sobject.
      # id      - The Salesforce ID of the record.
      #
      # Examples
      #
      #   # Delete the Account with Id '0016000000MRatd'
      #   client.destroy('Account', '0016000000MRatd')
      #
      # Returns true if the sobject was successfully deleted.
      # Returns false if an error is returned from Salesforce.
      def destroy(*args)
        destroy!(*args)
      rescue *exceptions
        false
      end

      # Public: Delete a record.
      #
      # sobject - String name of the sobject.
      # id      - The Salesforce ID of the record.
      #
      # Examples
      #
      #   # Delete the Account with Id '0016000000MRatd'
      #   client.destroy('Account', '0016000000MRatd')
      #
      # Returns true of the sobject was successfully deleted.
      # Raises an exception if an error is returned from Salesforce.
      def destroy!(sobject, id)
        api_delete "sobjects/#{sobject}/#{ERB::Util.url_encode(id)}"
        true
      end

      # Public: Finds a single record and returns all fields.
      #
      # sobject - The String name of the sobject.
      # id      - The id of the record. If field is specified, id should be the id
      #           of the external field.
      # field   - External ID field to use (default: nil).
      #
      # Returns the Restforce::SObject sobject record.
      def find(sobject, id, field = nil)
        url = if field
                "sobjects/#{sobject}/#{field}/#{ERB::Util.url_encode(id)}"
              else
                "sobjects/#{sobject}/#{ERB::Util.url_encode(id)}"
              end
        api_get(url).body
      end

      # Public: Finds a single record and returns select fields.
      #
      # sobject - The String name of the sobject.
      # id      - The id of the record. If field is specified, id should be the id
      #           of the external field.
      # select  - A String array denoting the fields to select.  If nil or empty array
      #           is passed, all fields are selected.
      # field   - External ID field to use (default: nil).
      #
      def select(sobject, id, select, field = nil)
        path = if field
                 "sobjects/#{sobject}/#{field}/#{ERB::Util.url_encode(id)}"
               else
                 "sobjects/#{sobject}/#{ERB::Util.url_encode(id)}"
               end

        path = "#{path}?fields=#{select.join(',')}" if select&.any?

        api_get(path).body
      end

      # Public: Finds recently viewed items for the logged-in user.
      #
      # limit - An optional limit that specifies the maximum number of records to be
      #         returned.
      #         If this parameter is not specified, the default maximum number of records
      #         returned is the maximum number of entries in RecentlyViewed, which is 200
      #         records per object.
      #
      # Returns an array of the recently viewed Restforce::SObject records.
      def recent(limit = nil)
        path = limit ? "recent?limit=#{limit}" : "recent"

        api_get(path).body
      end

      private

      # Internal: Returns a path to an api endpoint
      #
      # Examples
      #
      #   api_path('sobjects')
      #   # => '/services/data/v24.0/sobjects'
      def api_path(path)
        "/services/data/v#{options[:api_version]}/#{path}"
      end

      # Internal: Ensures that the `api_version` set for the Restforce client is at least
      # the provided version before performing a particular action
      def version_guard(version)
        if version.to_f <= options[:api_version].to_f
          yield
        else
          raise APIVersionError, "You must set an `api_version` of at least #{version} " \
                                 "to use this feature in the Salesforce API. Set the " \
                                 "`api_version` option when configuring the client - " \
                                 "see https://github.com/ejholmes/restforce/blob/master" \
                                 "/README.md#api-versions"
        end
      end

      def extract_case_insensitive_string_or_symbol_key_from_hash!(hash, key)
        value = hash.delete(key.to_sym)
        value ||= hash.delete(key.to_s)
        value ||= hash.delete(key.to_s.downcase)
        value ||= hash.delete(key.to_s.downcase.to_sym)
        value
      end

      # Internal: Errors that should be rescued from in non-bang methods
      def exceptions
        [Faraday::Error]
      end
    end
  end
end

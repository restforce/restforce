# frozen_string_literal: true

module Restforce
  module Concerns
    module Picklists
      # Public: Get the available picklist values for a picklist or multipicklist field.
      #
      # sobject - The String name of the sobject.
      # field   - The String name of the picklist/multipicklist field.
      # options - A hash of options. (default: {}).
      #           :valid_for - If specified, will only return picklist values
      #                        that are valid for the controlling picklist
      #                        value
      #
      # Examples
      #
      #   client.picklist_values('Account', 'Type')
      #   # => [#<Restforce::Mash label="Prospect" value="Prospect">]
      #
      #   # Given a custom object named Automobile__c with picklist fields
      #   # Model__c and Make__c, where Model__c depends on the value of
      #   # Make__c.
      #   client.picklist_values('Automobile__c', 'Model__c', :valid_for => 'Honda')
      #   # => [#<Restforce::Mash label="Civic" value="Civic">, ... ]
      #
      # Returns an array of Restforce::Mash objects.
      def picklist_values(sobject, field, options = {})
        PicklistValues.new(describe(sobject)['fields'], field, options)
      end

      class PicklistValues < Array
        def initialize(fields, field, options = {})
          @fields = fields
          @field = field
          @valid_for = options.delete(:valid_for)
          raise "#{field} is not a dependent picklist" if @valid_for && !dependent?

          super(picklist_values)
        end

        private

        attr_reader :fields

        def picklist_values
          if valid_for?
            field['picklistValues'].select { |picklist_entry| valid? picklist_entry }
          else
            field['picklistValues']
          end
        end

        # Returns true of the given field is dependent on another field.
        def dependent?
          !!field['dependentPicklist']
        end

        def valid_for?
          !!@valid_for
        end

        def controlling_picklist
          @_controlling_picklist ||= controlling_field['picklistValues'].
                                     find do |picklist_entry|
                                       picklist_entry['value'] == @valid_for
                                     end
        end

        def index
          @_index ||= controlling_field['picklistValues'].index(controlling_picklist)
        end

        def controlling_field
          @_controlling_field ||= fields.find { |f| f['name'] == field['controllerName'] }
        end

        def field
          @_field ||= fields.find { |f| f['name'] == @field }
        end

        # Returns true if the picklist entry is valid for the controlling picklist.
        #
        # See http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_des
        # cribesobjects_describesobjectresult.htm
        def valid?(picklist_entry)
          valid_for = picklist_entry['validFor'].ljust(16, 'A').unpack1('m').
                      unpack('C*')
          (valid_for[index >> 3] & (0x80 >> (index % 8))).positive?
        end
      end
    end
  end
end

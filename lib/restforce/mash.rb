# frozen_string_literal: true

require 'hashie/mash'

module Restforce
  class Mash < Hashie::Mash
    disable_warnings if respond_to?(:disable_warnings)

    class << self
      # Pass in an Array or Hash and it will be recursively converted into the
      # appropriate Restforce::Collection, Restforce::SObject and
      # Restforce::Mash objects.
      def build(val, client)
        case val
        when Array
          val.collect { |a_val| self.build(a_val, client) }
        when Hash
          self.klass(val).new(val, client)
        else
          val
        end
      end

      # When passed a hash, it will determine what class is appropriate to
      # represent the data.
      def klass(val)
        if val.key? 'records'
          # When the hash has a records key, it should be considered a collection
          # of sobject records.
          Restforce::Collection
        elsif val.key? 'attributes'
          case val.dig('attributes', 'type')
          when "Attachment"
            Restforce::Attachment
          when "Document"
            Restforce::Document
          else
            # When the hash contains an attributes key, it should be considered an
            # sobject record
            Restforce::SObject
          end
        else
          # Fallback to a standard Restforce::Mash for everything else
          Restforce::Mash
        end
      end
    end

    def initialize(source_hash = nil, client = nil, default = nil, &blk)
      @client = client
      deep_update(source_hash) if source_hash
      default ? super(default) : super(&blk)
    end

    def dup
      self.class.new(self, @client, self.default)
    end

    # The #convert_value method and its signature are part of Hashie::Mash's API, so we
    # can't unilaterally decide to change `duping` to be a keyword argument
    # rubocop:disable Style/OptionalBooleanParameter
    def convert_value(val, duping = false)
      case val
      when self.class
        val.dup
      when ::Hash
        val = val.dup if duping
        self.class.klass(val).new(val, @client)
      when Array
        val.collect { |e| convert_value(e) }
      else
        val
      end
    end
    # rubocop:enable Style/OptionalBooleanParameter
  end
end

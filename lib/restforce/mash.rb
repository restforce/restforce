require 'hashie/mash'

module Restforce
  class Mash < Hashie::Mash

    class << self

      # Pass in an Array or Hash and it will be recursively converted into the
      # appropriate Restforce::Collection, Restforce::SObject and
      # Restforce::Mash objects.
      def build(val, client)
        if val.is_a?(Array)
          val.collect { |e| self.type(e).new(e, client) }
        else
          self.type(val).new(val, client)
        end
      end

      # When passed a hash, it will determine what class is appropriate to
      # represent the data.
      def type(val)
        # When the hash has a records key, it should be considered a collection
        # of sobject records.
        if val.has_key? 'records'
          Restforce::Collection
        # When the has contains an attributes key, it should be considered an
        # sobject record
        elsif val.has_key? 'attributes'
          Restforce::SObject
        # Fallback to a standard Restforce::Mash for everything else
        else
          Restforce::Mash
        end
      end

    end

    def initialize(source_hash = nil, client = nil, default = nil, &blk)
      @client = client
      deep_update(source_hash) if source_hash
      default ? super(default) : super(&blk)
    end
  
    def convert_value(val, duping=false)
      case val
      when self.class
        val.dup
      when ::Hash
        val = val.dup if duping
        # If the hash has a 'records' key, then it's a collection
        # of sobject records.
        self.class.type(val).new(val, @client)
      when Array
        val.collect{ |e| convert_value(e) }
      else
        val
      end
    end

  end
end

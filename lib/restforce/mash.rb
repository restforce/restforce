require 'hashie/mash'

module Restforce
  class Mash < Hashie::Mash

    class << self

      def build(val, client)
        self.type(val).new(val, client)
      end

      def type(val)
        if val.has_key? 'records'
          Restforce::Collection
        elsif val.has_key? 'attributes'
          Restforce::SObject
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

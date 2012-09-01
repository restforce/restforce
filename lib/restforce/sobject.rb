module Restforce
  class SObject < Hashie::Mash

    def initialize(source_hash = nil, default = nil, &blk)
      deep_update(source_hash) if source_hash
      default ? super(default) : super(&blk)
    end

    def sobject_type
      self.attributes.type
    end

    def convert_value(val, duping=false)
      case val
      when self.class
        val.dup
      when ::Hash
        val = val.dup if duping
        # If the hash has a 'records' key, then it's a collection
        # of sobject records.
        if val.has_key? 'records'
          Restforce::Collection.new(val)
        elsif val.has_key? 'attributes'
          Restforce::SObject.new(val)
        else
          Hashie::Mash.new.merge(val)
        end
      when Array
        val.collect{ |e| convert_value(e) }
      else
        val
      end
    end

  end
end

module Restforce
  class SObject < Hashie::Mash
    attr_reader :sobject_type

    def initialize(source_hash = nil, default = nil, &blk)
      attributes = source_hash.delete('attributes')
      @sobject_type = attributes['type']
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
        if val.has_key? 'records'
          Restforce::Collection.new(val)
        else
          self.class.new(val)
        end
      when Array
        val.collect{ |e| convert_value(e) }
      else
        val
      end
    end

  end
end

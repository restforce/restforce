module Restforce
  class SObject < Restforce::Mash

    def initialize(source_hash = nil, client = nil, default = nil, &blk)
      @client = client
      deep_update(source_hash) if source_hash
      default ? super(default) : super(&blk)
    end

    def sobject_type
      self.attributes.type
    end

  end
end

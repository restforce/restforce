require 'hashie/mash'

module Restforce
  class Mash < Hashie::Mash
  
    def convert_value(val, duping=false)
      case val
      when self.class
        val.dup
      when ::Hash
        val = val.dup if duping
        # If the hash has a 'records' key, then it's a collection
        # of sobject records.
        if val.has_key? 'records'
          Restforce::Collection.new(val, @client)
        elsif val.has_key? 'attributes'
          Restforce::SObject.new(val, @client)
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

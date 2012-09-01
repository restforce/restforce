module Restforce
  class SObject < Restforce::Mash

    def sobject_type
      self.attributes.type
    end

  end
end

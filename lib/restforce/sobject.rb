module Restforce
  class SObject < Restforce::Mash

    def sobject_type
      self.attributes.type
    end

    # Public: Persist the attributes to Salesforce.
    #
    # Examples
    #
    #   account = client.query('select Id, Name from Account').first
    #   account.Name = 'Foobar'
    #   account.save
    def save
      # Remove 'attributes' and parent/child relationships. We only want to
      # persist the attributes on the sobject.
      ensure_id
      attrs = self.to_hash.reject { |key, _| key =~ /.*__r/ || key =~ /^attributes$/ }
      @client.update(sobject_type, attrs)
    end

    # Public: Destroy this record.
    #
    # Examples
    #
    #   account = client.query('select Id, Name from Account').first
    #   account.destroy
    def destroy
      ensure_id
      @client.destroy(sobject_type, self.Id)
    end

  private

    def ensure_id
      raise 'You need to query the Id for the record first.' unless self.Id?
    end

  end
end

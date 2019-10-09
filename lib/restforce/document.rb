# frozen_string_literal: true

module Restforce
  class Document < Restforce::SObject
    # Public: Returns the body of the document.
    #
    # Examples
    #
    #   document = client.query('select Id, Name, Body from Document').first
    #   File.open(document.Name, 'wb') { |f| f.write(document.Body) }
    def Body
      ensure_id && ensure_body
      @client.get(super).body
    end

    private

    def ensure_body
      return true if self.Body?

      raise 'You need to query the Body for the record first.'
    end
  end
end

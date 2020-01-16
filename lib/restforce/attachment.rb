# frozen_string_literal: true

module Restforce
  class Attachment < Restforce::SObject
    # Public: Returns the body of the attachment.
    #
    # Examples
    #
    #   attachment = client.query('select Id, Name, Body from Attachment').first
    #   File.open(attachment.Name, 'wb') { |f| f.write(attachment.Body) }
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

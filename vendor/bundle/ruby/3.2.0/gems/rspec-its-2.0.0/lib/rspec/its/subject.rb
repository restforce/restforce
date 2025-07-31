# frozen_string_literal: true

module RSpec
  module Its
    # @api private
    # Handles turning subject into an expectation target
    module Subject
      def for(attribute, subject)
        if Array === attribute
          if Hash === subject
            attribute.inject(subject) { |inner, attr| inner[attr] }
          else
            subject[*attribute]
          end
        else
          attribute_chain = attribute.to_s.split('.')
          attribute_chain.inject(subject) do |inner_subject, attr|
            inner_subject.public_send(attr)
          end
        end
      end

      module_function :for
    end
  end
end

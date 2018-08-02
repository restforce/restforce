# frozen_string_literal: true

module Faraday
  module Parts
    module Part
      def self.new(boundary, name, value, headers = {})
        headers ||= {}
        if value.respond_to? :content_type
          FilePart.new(boundary, name, value)
        else
          ParamPart.new(boundary, name, value, headers)
        end
      end
    end

    class ParamPart
      def initialize(boundary, name, value, headers = {})
        @part = build_part(boundary, name, value, headers)
        @io = StringIO.new(@part)
      end

      def build_part(boundary, name, value, headers = {})
        part = ''
        part << "--#{boundary}\r\n"
        part << "Content-Disposition: form-data; name=\"#{name}\"\r\n"
        part << "Content-Type: #{headers['Content-Type']}\r\n" if headers["Content-Type"]
        part << "\r\n"
        part << "#{value}\r\n"
      end
    end
  end
end

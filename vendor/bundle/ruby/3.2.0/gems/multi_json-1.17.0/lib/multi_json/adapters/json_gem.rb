require_relative "../adapter"
require "json"

module MultiJson
  module Adapters
    # Use the JSON gem to dump/load.
    class JsonGem < Adapter
      ParseError = ::JSON::ParserError

      defaults :load, create_additions: false, quirks_mode: true

      PRETTY_STATE_PROTOTYPE = {
        indent: "  ",
        space: " ",
        object_nl: "\n",
        array_nl: "\n"
      }.freeze
      private_constant :PRETTY_STATE_PROTOTYPE

      def load(string, options = {})
        string = string.dup.force_encoding(Encoding::UTF_8) if string.encoding != Encoding::UTF_8

        options[:symbolize_names] = true if options.delete(:symbolize_keys)
        ::JSON.parse(string, options)
      end

      def dump(object, options = {})
        options.merge!(PRETTY_STATE_PROTOTYPE) if options.delete(:pretty)

        object.to_json(options)
      end
    end
  end
end

require "oj"
require_relative "../adapter"

module MultiJson
  module Adapters
    # Use the Oj library to dump/load.
    class Oj < Adapter
      defaults :load, mode: :strict, symbolize_keys: false
      defaults :dump, mode: :compat, time_format: :ruby, use_to_json: true

      # In certain cases OJ gem may throw JSON::ParserError exception instead
      # of its own class. Also, we can't expect ::JSON::ParserError and
      # ::Oj::ParseError to always be defined, since it's often not the case.
      # Because of this, we can't reference those classes directly and have to
      # do string comparison instead. This will not catch subclasses, but it
      # shouldn't be a problem since the library is not known to be using it
      # (at least for now).
      class ParseError < ::SyntaxError
        WRAPPED_CLASSES = %w[Oj::ParseError JSON::ParserError].freeze
        private_constant :WRAPPED_CLASSES

        def self.===(exception)
          exception.is_a?(::SyntaxError) || WRAPPED_CLASSES.include?(exception.class.to_s)
        end
      end

      def load(string, options = {})
        options[:symbol_keys] = options[:symbolize_keys]
        ::Oj.load(string, options)
      end

      OJ_VERSION = ::Oj::VERSION
      OJ_V2 = OJ_VERSION.start_with?("2.")
      OJ_V3 = OJ_VERSION.start_with?("3.")
      private_constant :OJ_VERSION, :OJ_V2, :OJ_V3

      if OJ_V3
        PRETTY_STATE_PROTOTYPE = {
          indent: "  ",
          space: " ",
          space_before: "",
          object_nl: "\n",
          array_nl: "\n",
          ascii_only: false
        }.freeze
        private_constant :PRETTY_STATE_PROTOTYPE
      end

      def dump(object, options = {})
        if OJ_V2
          options[:indent] = 2 if options[:pretty]
          options[:indent] = options[:indent].to_i if options[:indent]
        elsif OJ_V3
          options.merge!(PRETTY_STATE_PROTOTYPE.dup) if options.delete(:pretty)
        else
          raise "Unsupported Oj version: #{::Oj::VERSION}"
        end

        ::Oj.dump(object, options)
      end
    end
  end
end

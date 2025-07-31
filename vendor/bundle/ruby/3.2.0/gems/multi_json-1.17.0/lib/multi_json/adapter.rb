require "singleton"
require_relative "options"

module MultiJson
  class Adapter
    extend Options
    include Singleton

    class << self
      BLANK_RE = /\A\s*\z/
      private_constant :BLANK_RE

      def defaults(action, value)
        value.freeze
        define_singleton_method("default_#{action}_options") { value }
      end

      def load(string, options = {})
        string = string.read if string.respond_to?(:read)
        raise self::ParseError if blank?(string)

        instance.load(string, cached_load_options(options))
      end

      def dump(object, options = {})
        instance.dump(object, cached_dump_options(options))
      end

      private

      def blank?(input)
        input.nil? || BLANK_RE.match?(input)
      rescue ArgumentError # invalid byte sequence in UTF-8
        false
      end

      def cached_dump_options(options)
        opts = options_without_adapter(options)
        OptionsCache.dump.fetch(opts) do
          dump_options(opts).merge(MultiJson.dump_options(opts)).merge!(opts)
        end
      end

      def cached_load_options(options)
        opts = options_without_adapter(options)
        OptionsCache.load.fetch(opts) do
          load_options(opts).merge(MultiJson.load_options(opts)).merge!(opts)
        end
      end

      def options_without_adapter(options)
        options[:adapter] ? options.except(:adapter) : options
      end
    end
  end
end

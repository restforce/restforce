module MultiJson
  module Options
    def load_options=(options)
      OptionsCache.reset
      @load_options = options
    end

    def dump_options=(options)
      OptionsCache.reset
      @dump_options = options
    end

    def load_options(*args)
      (defined?(@load_options) && get_options(@load_options, *args)) || default_load_options
    end

    def dump_options(*args)
      (defined?(@dump_options) && get_options(@dump_options, *args)) || default_dump_options
    end

    def default_load_options
      @default_load_options ||= {}.freeze
    end

    def default_dump_options
      @default_dump_options ||= {}.freeze
    end

    private

    def get_options(options, *args)
      return handle_callable_options(options, *args) if options_callable?(options)

      handle_hashable_options(options)
    end

    def options_callable?(options)
      options.respond_to?(:call)
    end

    def handle_callable_options(options, *args)
      options.arity.zero? ? options.call : options.call(*args)
    end

    def handle_hashable_options(options)
      options.respond_to?(:to_hash) ? options.to_hash : nil
    end
  end
end

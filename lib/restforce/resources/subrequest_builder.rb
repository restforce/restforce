# frozen_string_literal: true

module Restforce
  module Resources
    module SubrequestBuilder
      def define_subrequest(subrequest_method, clazz, http_method, *params)
        define_method subrequest_method do |*args|
          clazz = clazz.is_a?(Class) ? clazz : Object.const_get(clazz)
          opts = {}
          params.each_with_index do |el, idx|
            opts[el] = args[idx]
          end
          if args.length > params.length && args[-1].is_a?(Hash)
            opts.merge!({ api_version: options[:api_version] }.merge(args[-1]))
          else
            opts[:api_version] = options[:api_version]
          end
          object = clazz.new(http_method, opts)
          yield(object) if block_given?
          object.opts = clazz.build_option_url(object.opts)
          requests << clazz.new(http_method, clazz.build_option_url(opts)).to_request
        end
      end

      def define_generic_subrequest(subrequest_method, clazz,
                                    http_methods, *params, &block)
        http_methods.each do |http_method|
          define_subrequest([http_method, subrequest_method].join('_'),
                            clazz,
                            http_method,
                            *params,
                            &block)
        end
      end
    end
  end
end

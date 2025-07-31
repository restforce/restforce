module MultiJson
  module ConvertibleHashKeys
    SIMPLE_OBJECT_CLASSES = [String, Numeric, TrueClass, FalseClass, NilClass].freeze
    private_constant :SIMPLE_OBJECT_CLASSES

    private

    def symbolize_keys(hash)
      prepare_hash(hash) do |key|
        key.respond_to?(:to_sym) ? key.to_sym : key
      end
    end

    def stringify_keys(hash)
      prepare_hash(hash) do |key|
        key.respond_to?(:to_s) ? key.to_s : key
      end
    end

    def prepare_hash(value, &block)
      case value
      when Array
        handle_array(value, &block)
      when Hash
        handle_hash(value, &block)
      else
        handle_simple_objects(value)
      end
    end

    def handle_simple_objects(obj)
      return obj if simple_object?(obj) || obj.respond_to?(:to_json)

      obj.respond_to?(:to_s) ? obj.to_s : obj
    end

    def handle_array(array, &key_modifier)
      array.map { |value| prepare_hash(value, &key_modifier) }
    end

    def handle_hash(original_hash, &key_modifier)
      original_hash.each_with_object({}) do |(key, value), result|
        result[key_modifier.call(key)] = prepare_hash(value, &key_modifier)
      end
    end

    def simple_object?(obj)
      SIMPLE_OBJECT_CLASSES.any? { |klass| obj.is_a?(klass) }
    end
  end
end

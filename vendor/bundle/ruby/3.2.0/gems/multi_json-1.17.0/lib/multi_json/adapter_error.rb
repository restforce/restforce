module MultiJson
  class AdapterError < ArgumentError
    def initialize(message = nil, cause: nil)
      super(message)
      set_backtrace(cause.backtrace) if cause
    end

    def self.build(original_exception)
      message = "Did not recognize your adapter specification (#{original_exception.message})."
      new(message, cause: original_exception)
    end
  end
end

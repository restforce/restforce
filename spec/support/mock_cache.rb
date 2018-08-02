# frozen_string_literal: true

class MockCache
  def initialize
    @storage = {}
  end

  def read(key)
    @storage[key]
  end

  def write(key, value)
    @storage[key] = value
  end

  def fetch(key)
    @storage[key] ||= yield
  end

  def delete(key)
    @storage.delete(key)
  end
end

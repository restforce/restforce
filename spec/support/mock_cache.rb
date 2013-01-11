class MockCache
  def initialize
    @storage = {}
  end

  def fetch(key, &block)
    @storage[key] ||= block.call
  end

  def delete(key)
    @storage.delete(key)
  end
end

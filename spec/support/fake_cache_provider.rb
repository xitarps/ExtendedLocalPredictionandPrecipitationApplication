class FakeCacheStore
  def initialize
    @store = {}
  end

  def read(key)
    @store[key]
  end

  def write(key, value, expires_in: nil)
    @store[key] = value
  end
end

class FakeCacheProvider
  attr_reader :cache

  def initialize
    @cache = FakeCacheStore.new
  end
end

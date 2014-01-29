class Plyushkin::Cache::Stub
  def initialize
    @cache = {}
  end

  def write(key, value)
    @cache[key] = value
  end

  def read(key)
    @cache[key]
  end
end

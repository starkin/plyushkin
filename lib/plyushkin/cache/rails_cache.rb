class Plyushkin::Cache::RailsCache
  def read(key)
    Rails.cache.read(key)
  end

  def write(key, value)
    Rails.cache.write(key, value)
  end
end

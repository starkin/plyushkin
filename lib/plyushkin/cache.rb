module Plyushkin::Cache
  class << self
    def cache
      @cache ||= Plyushkin::Cache::Stub.new
    end

    def cache=(value)
      @cache = value
    end
  end
end

require File.dirname(File.expand_path(__FILE__)) + "/cache/stub"
require File.dirname(File.expand_path(__FILE__)) + "/cache/rails_cache"

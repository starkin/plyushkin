require_relative "matcher_base.rb"
require_relative "persisted_attribute_matcher.rb"
require_relative "hoarded_attribute_matcher.rb"

module Plyushkin::Test
  module Matchers
    def persist_attribute(name)
      Plyushkin::Test::PersistedAttributeMatcher.new(name) 
    end

    def hoard(attribute)
      Plyushkin::Test::HoardedAttributeMatcher.new(attribute)
    end
  end
end

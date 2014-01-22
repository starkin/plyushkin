module Plyushkin::Test
  class Plyushkin::Test::PresenceTestValue < Plyushkin::BaseValue
    persisted_attr :value
    validates :value, :presence => true
  end

  class Plyushkin::Test::CoordinateValue < Plyushkin::BaseValue
    persisted_attr :x, :y
    validates :x, :y, :presence => true
  end

  class Plyushkin::Test::Member < ActiveRecord::Base; end

  class Plyushkin::Test::DateValue < Plyushkin::BaseValue
    persisted_attr :value, :formatter => :to_date
  end
end

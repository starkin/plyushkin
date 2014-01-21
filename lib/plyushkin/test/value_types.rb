module Plyushkin::Test
  class Plyushkin::Test::PresenceTestValue < Plyushkin::BaseValue
    persisted_attr :value
    validates :value, :presence => true
  end

  class Plyushkin::Test::CoordinateValue < Plyushkin::BaseValue
    persisted_attr :x, :y
    validates :x, :y, :presence => true
  end
end

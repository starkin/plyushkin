module Elephant::Test
  class Elephant::Test::PresenceTestValue < Elephant::BaseValue
    persisted_attr :value
    validates :value, :presence => true
  end

  class Elephant::Test::CoordinateValue < Elephant::BaseValue
    persisted_attr :x, :y
    validates :x, :y, :presence => true
  end
end

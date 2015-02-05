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
  class Plyushkin::Test::WidgetOne < ActiveRecord::Base; hoards :apples; end
  class Plyushkin::Test::WidgetTwo < ActiveRecord::Base; hoards :beans; end
  class Plyushkin::Test::IgnoresUnchangedWidget < ActiveRecord::Base
    hoards :apples, :ignore_unchanged_values => true
    hoards :beans
  end

  class Plyushkin::Test::CallbackWidget < ActiveRecord::Base
    hoards :apples, :after_create => :core
    hoards :beans
  end

  class Plyushkin::Test::DateValue < Plyushkin::BaseValue
    persisted_attr :value, :formatter => :to_date
    persisted_attr :is_deleted, :formatter => :to_bool
  end

  class Plyushkin::Test::ComplexModel < ActiveRecord::Base
    hoards :coordinate, :type => Plyushkin::Test::CoordinateValue
  end

  class Plyushkin::Test::FilteredModel < ActiveRecord::Base
    hoards :is_deleted, :type => Plyushkin::Test::DateValue, :filter => :test_filter 
    
    def test_filter(value)
      true
    end
  end
end

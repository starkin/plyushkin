require 'spec_helper'

describe Plyushkin::BaseValue do
  describe '#valid?' do
    it 'should not be valid user-defined value if validations fail' do
      value = Plyushkin::Test::CoordinateValue.new
      value.valid?
      value.errors.count.should == 2
    end

    it 'should be valid user-defined value if validations pass' do
      value = Plyushkin::Test::CoordinateValue.new(:x => 5, :y => 10)
      value.valid?
      value.errors.count.should == 0
    end

    it 'should not be valid if date is in the future' do
      value = Plyushkin::SimpleValue.new(:date => 2.days.from_now)
      value.should_not be_valid
      value.errors.full_messages.should == ["Date cannot be in the future"]
    end
  end

  describe '##persisted_attr' do
    it 'should add attribute to persisted_attributes' do
      clazz = Class.new(Plyushkin::BaseValue) do
        persisted_attr :my_attr
      end

      clazz.persisted_attributes.should == [ :date, :my_attr ]
    end

    it 'should add attributes to persisted_attributes when called multiple times' do
      clazz = Class.new(Plyushkin::BaseValue) do
        persisted_attr :my_attr
        persisted_attr :my_other_attr
      end

      clazz.persisted_attributes.should == [ :date, :my_attr, :my_other_attr ]
    end

    it 'should add attributes to persisted_attributes when called with multiple attributes' do
      clazz = Class.new(Plyushkin::BaseValue) do
        persisted_attr :my_attr, :my_other_attr
      end

      clazz.persisted_attributes.should == [ :date, :my_attr, :my_other_attr ]
    end

    it 'should add reader and writer for attribute' do
      clazz = Class.new(Plyushkin::BaseValue) do
        persisted_attr :my_attr
      end

      value = clazz.new
      value.my_attr = 5
      value.my_attr.should == 5
    end

    it "should format value readers using format methods when specified" do
      clazz = Class.new(Plyushkin::BaseValue) do
        persisted_attr :my_attr, :formatter => :to_i
      end

      value = clazz.new
      value.my_attr = "5"
      value.my_attr.should == 5
    end
    
    it "should format multiple value readers using format methods when specified" do
      clazz = Class.new(Plyushkin::BaseValue) do
        persisted_attr :my_attr, :my_attr2, :formatter => :to_i
      end

      value = clazz.new
      value.my_attr = "5"
      value.my_attr2 = "9999"
      value.my_attr.should == 5
      value.my_attr2.should == 9999

    end

  end

  describe '#equal_value' do
    it 'should test equality of persisted_attributes' do
      clazz = Class.new(Plyushkin::BaseValue) do
        persisted_attr :my_attr, :my_attr2
      end

      value1 = clazz.new
      value1.my_attr = 5
      value1.my_attr2 = "test"

      value2 = clazz.new
      value2.my_attr = 5
      value2.my_attr2 = "test"

      value1.equal_value?(value2).should  be_true
    end

    it 'should be true if dates are different' do
      clazz = Class.new(Plyushkin::BaseValue) do
        persisted_attr :my_attr, :my_attr2
      end

      value1 = clazz.new
      value1.my_attr = 5
      value1.my_attr2 = "test"
      value1.date = DateTime.now - 3.days

      value2 = clazz.new
      value2.my_attr = 5
      value2.my_attr2 = "test"
      value2.date = DateTime.now - 5.days

      value1.equal_value?(value2).should  be_true

    end
  end
end

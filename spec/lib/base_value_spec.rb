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
      value = Plyushkin::StringValue.new(:date => 2.days.from_now)
      value.should_not be_valid
      value.errors.full_messages.should == ["Date cannot be in the future"]
    end

    it 'should be valid if date is equal to now' do
      Timecop.freeze(DateTime.now) do
        Plyushkin::StringValue.new.should be_valid
      end
    end

    it 'should be valid if date is equal to current' do
      Timecop.freeze(DateTime.current) do
        Plyushkin::StringValue.new.should be_valid
      end
    end

    describe '#numericality' do
      it 'should not be valid if not an integer' do
        clazz = Class.new(Plyushkin::StringValue) do
          validates :value, :numericality => true
        end
        clazz.stub(:name).and_return("Clazz")

        c = clazz.new
        c.value = 'abcd'
        c.should_not be_valid
      end
    end
  end

  describe '#new_record?' do
    it 'should be true for a new instance' do
      clazz = Class.new(Plyushkin::StringValue) 
      clazz.new.should be_new_record
    end
  end

  describe '#mark_persisted' do
    it 'should set new_record to false' do
      clazz = Class.new(Plyushkin::StringValue) 
      value = clazz.new
      value.mark_persisted
      value.should_not be_new_record
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

  describe 'formatter methods' do
    describe '#to_i' do
      it 'should return the same value if it contains non-numeric characters' do
        Plyushkin::BaseValue.new.to_i("abcd").should == "abcd"
      end

      it 'should return an integer if string is a number' do
        Plyushkin::BaseValue.new.to_i("1234").should == 1234
      end

      it 'should return an integer if arg is an integer' do
        Plyushkin::BaseValue.new.to_i(1234).should == 1234
      end

      it 'should return nil when arg is nil' do
        Plyushkin::BaseValue.new.to_i(nil).should be_nil
      end
    end

    describe '#to_f' do
      it 'should return the same value if it contains non-numeric characters' do
        Plyushkin::BaseValue.new.to_f("abcd").should == "abcd"
      end

      it 'should return a float if string is a number' do
        Plyushkin::BaseValue.new.to_f("12.34").should == 12.34
      end

      it 'should return a float if arg is a float' do
        Plyushkin::BaseValue.new.to_f(123.4).should == 123.4
      end

      it 'should return a float if arg is an integer' do
        Plyushkin::BaseValue.new.to_f(455).should == 455.0
      end

      it 'should return nil when arg is nil' do
        Plyushkin::BaseValue.new.to_f(nil).should be_nil
      end
    end

    describe '#to_date' do
      it 'format a json string to a date' do
        value = Plyushkin::BaseValue.new
        now = DateTime.now
        value.to_date(now.to_json).should === now
      end
    end

    describe '#to_bool' do
      it 'should return true if string true is passed in' do
        Plyushkin::BaseValue.new.to_bool("true").should be_true
      end

      it 'should return false if string false is passed in' do
        Plyushkin::BaseValue.new.to_bool("false").should be_false
      end

      it 'should return nil if nil is passed in' do
        Plyushkin::BaseValue.new.to_bool(nil).should be_nil
      end

      it 'should return the same value if it cannot covert to boolean' do
        Plyushkin::BaseValue.new.to_bool('railsconf').should == 'railsconf'
      end
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

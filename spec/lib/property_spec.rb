require 'spec_helper'

describe Plyushkin::Property do
  describe '#create' do
    it 'should add a SimpleValue' do
      property = Plyushkin::Property.new(:property_name)
      value = property.create(:value => 5)
      value.class.should == Plyushkin::SimpleValue
    end

    it 'should pass the attributes to the simple value' do
      property = Plyushkin::Property.new(:property_name)
      date     = DateTime.now - 3.days
      value    = property.create(:value => 5, :date => date)
      value.value.should == 5
      value.date.should  == date
    end

    it 'should add a user-defined value' do
      property = Plyushkin::Property.new(:property_name, :type => Plyushkin::Test::CoordinateValue)
      value    = property.create(:x => 5, :y => 10)
      value.class.should == Plyushkin::Test::CoordinateValue
      value.x.should     == 5
      value.y.should     == 10
    end

    describe 'callbacks' do
      it 'should call after_create callback after create' do
        called = 0
        callbacks = { :after_create => lambda{ called += 1 } }
        property = Plyushkin::Property.new(:property_name, :callbacks => callbacks)
        property.create(:value => 5)
        called.should == 1
        property.last.value.should == 5
      end

      it 'should not require an after_create callback' do
        called = 0
        callbacks = { :before_create => lambda{ called += 1 } }
        property = Plyushkin::Property.new(:property_name, :callbacks => callbacks)
        property.create(:value => 5)
        called.should == 0
      end
    end

    describe 'ignore_unchanged_value' do
      it 'should not add a value when ignore_unchanged_value is true and value does not change' do
        property = Plyushkin::Property.new(:property_name, :ignore_unchanged_values => true)
        property.create(:value => 5)
        property.create(:value => 5)
        property.all.length.should == 1
      end
    end
  end

  describe '#all' do
    it 'should return an array of all created values' do
      property = Plyushkin::Property.new(:property_name)
      value1 = property.create(:value => 5)
      value2 = property.create(:value => 7)
      property.all.should == [ value1, value2 ]
    end

    it 'should be sorted by value class date' do
      property = Plyushkin::Property.new(:property_name)
      value1 = property.create(:value => 5, :date => DateTime.now - 5.days)
      value2 = property.create(:value => 7, :date => DateTime.now - 7.days)
      property.all.should == [ value2, value1 ]
    end
  end

  describe '#last' do
    it 'should return the most-recently added value' do
      property = Plyushkin::Property.new(:property_name)
      value1 = property.create(:value => 5)
      value2 = property.create(:value => 7)
      property.last.should == value2
    end

    it 'should return a new value if there are no values' do
      property = Plyushkin::Property.new(:property_name)
      property.last.should be_a(Plyushkin::NilValue)
    end
  end

  describe '#valid?' do
    it 'should be valid if no values exist' do
      property = Plyushkin::Property.new(:property_name)
      property.should be_valid
    end

    it 'should be valid if last is valid and other values in array are not valid' do
      property = Plyushkin::Property.new(:property_name, :type => Plyushkin::Test::PresenceTestValue)
      value1 = property.create
      value2 = property.create(:value => 5)
      property.should be_valid
    end

    it 'should not be valid if last is not valid' do
      property = Plyushkin::Property.new(:property_name, :type => Plyushkin::Test::PresenceTestValue)
      value1 = property.create(:value => 5)
      value2 = property.create
      property.should_not be_valid
    end

    it 'should populate errors from values when not valid' do
      property = Plyushkin::Property.new(:histprop, :type => Plyushkin::Test::PresenceTestValue)
      property.create
      property.valid?
      property.errors.full_messages.should == [ "Histprop: Value can't be blank" ]
    end
  end

  describe '#empty?' do
    it 'should return true if no values were created' do
      property = Plyushkin::Property.new(:histprop, :type => Plyushkin::Test::PresenceTestValue)
      property.should be_empty
    end

    it 'should return false if values were not created' do
      property = Plyushkin::Property.new(:histprop, :type => Plyushkin::Test::PresenceTestValue)
      property.create
      property.should_not be_empty
    end
  end

  it '#insert_position' do
    property = Plyushkin::Property.new(:property_name)
    value1 = property.create(:value => 7, :date => DateTime.now - 7.days)
    value2 = property.create(:value => 5, :date => DateTime.now - 5.days)
    property.insert_position(DateTime.now).should == 2
    property.insert_position(DateTime.now - 6.days).should == 1
    property.insert_position(DateTime.now - 8.days).should == 0
  end

end

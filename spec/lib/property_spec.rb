require 'spec_helper'

describe Plyushkin::Property do
  describe '##load' do
    it 'should mark all values as not new records' do
      property = Plyushkin::Property.load(:name, Plyushkin::StringValue,
                                [ {:value => 'test'} ])
      property.last.should_not be_new_record
    end
  end

  describe '#create' do
    it 'should add a StringValue' do
      property = Plyushkin::Property.new(:property_name)
      value = property.create(:value => 5)
      value.class.should == Plyushkin::StringValue
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

    describe '#dirty?' do
      let(:property) { Plyushkin::Property.new(:property_name) }

      it 'should be false when the property is first created' do
        property.should_not be_dirty
      end

      it 'should be true when a value is created' do
        property.create(:value => 5)
        property.should be_dirty
      end
    end

    describe '#mark_persisted' do
      let(:property) { Plyushkin::Property.new(:property_name) }

      it 'should reset dirty? to false' do
        property.create(:value => 5)
        property.should be_dirty
        property.mark_persisted
        property.should_not be_dirty
      end

      it 'should mark all values new_record to false' do
        property.create(:value => 5)
        property.last.should be_new_record
        property.mark_persisted
        property.last.should_not be_new_record
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

    describe 'ignore_invalid option' do
      it 'should not create a value if value is invalid and option is true' do
        property = Plyushkin::Property.new(:property_name, :type => Plyushkin::Test::PresenceTestValue)
        property.create(:ignore_invalid => true )
        property.all.length.should == 0
        property.should be_valid
      end

      it 'should create a value if the value is invalid and the option is not provided' do
        property = Plyushkin::Property.new(:property_name,
                                          :type => Plyushkin::Test::PresenceTestValue)
        property.create
        property.all.length.should == 1
        property.should_not be_valid
      end

      it 'should create a value if the value is valid and the option is true' do
        property = Plyushkin::Property.new(:property_name,
                                          :type => Plyushkin::Test::PresenceTestValue)
        property.create(:value => 5, :ignore_invalid => true)
        property.all.length.should == 1
        property.should be_valid
      end
    end

    describe 'new_record' do
      it 'should not run callbacks if option is false' do
        called = 0
        callbacks = { :after_create => lambda{ called += 1 } }
        property = Plyushkin::Property.new(:property_name, :callbacks => callbacks)
        property.create(:value => 5, :new_record => false)
        called.should == 0
      end

      it 'should run callbacks if option is true' do
        called = 0
        callbacks = { :after_create => lambda{ called += 1 } }
        property = Plyushkin::Property.new(:property_name, :callbacks => callbacks)
        property.create(:value => 5, :new_record => true)
        called.should == 1
      end

      it 'should run callbacks if no option is provided' do
        called = 0
        callbacks = { :after_create => lambda{ called += 1 } }
        property = Plyushkin::Property.new(:property_name, :callbacks => callbacks)
        property.create(:value => 5)
        called.should == 1
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

    it 'should apply a default filter, if defined' do
      property = Plyushkin::Property.new(:property_name, :filter => Proc.new { |v| v.value > 5 })
      value1 = property.create(:value => 5, :date => DateTime.now - 5.days)
      value2 = property.create(:value => 7, :date => DateTime.now - 7.days)
      property.all.should == [ value2 ]
    end

    it 'should return all data if :unfiltered => true' do
      property = Plyushkin::Property.new(:property_name, :filter => Proc.new { |v| v.value > 5 })
      value1 = property.create(:value => 5, :date => DateTime.now - 5.days)
      value2 = property.create(:value => 7, :date => DateTime.now - 7.days)
      property.all(:unfiltered => true).should == [ value2, value1 ]
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
      property = Plyushkin::Property.new(:property_name, :type => Plyushkin::Test::PresenceTestValue)
      property.create
      property.valid?
      property.errors.full_messages.should == [ "PropertyName: Value can't be blank" ]
    end
  end

  describe '#empty?' do
    it 'should return true if no values were created' do
      property = Plyushkin::Property.new(:property_name, :type => Plyushkin::Test::PresenceTestValue)
      property.should be_empty
    end

    it 'should return false if values were not created' do
      property = Plyushkin::Property.new(:property_name, :type => Plyushkin::Test::PresenceTestValue)
      property.create
      property.should_not be_empty
    end
  end

  describe '#nil?' do
    it 'should be true if last value is NilValue' do
      property = Plyushkin::Property.new(:property_name, :type => Plyushkin::Test::PresenceTestValue)
      property.should be_nil
    end

    it 'should be false if last value is not a NilValue' do
      property = Plyushkin::Property.new(:property_name, :type => Plyushkin::Test::PresenceTestValue)
      property.create
      property.should_not be_nil
    end
  end

  describe '#insert_position' do
    it 'should get position in date order' do
      property = Plyushkin::Property.new(:property_name)
      value1 = property.create(:value => 7, :date => DateTime.now - 7.days)
      value2 = property.create(:value => 5, :date => DateTime.now - 5.days)
      property.insert_position(DateTime.now).should == 2
      property.insert_position(DateTime.now - 6.days).should == 1
      property.insert_position(DateTime.now - 8.days).should == 0
    end
  end

  describe '#value_hashes' do
    let(:property) { Plyushkin::Property.new(:property_name) }

    it 'should include all values as hashes in an array' do

      p1 = property.create(:value => 1)
      p2 = property.create(:value => 2)
      property.value_hashes.should == [
        { :date => p1.date, :value => 1 },
        { :date => p2.date, :value => 2 }
      ]
    end

    it 'should include all attributes in value hash' do
      property = Plyushkin::Property.new(:property_name, :type => Plyushkin::Test::CoordinateValue)

      c1 = property.create(:x => 5,  :y => 10)
      c2 = property.create(:x => 15, :y => 20)
      property.value_hashes.should == [
        { :date => c1.date, :x => 5,  :y => 10 },
        { :date => c2.date, :x => 15, :y => 20 }
      ]

    end

    it 'should be an empty array if no values are set' do
      property.value_hashes.should == []
    end

  end

end

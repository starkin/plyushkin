require 'spec_helper'

describe ActiveRecord::Base do
  describe '##hoards' do
    describe 'read' do
      it 'should return the same property instance when called multiple times' do
        clazz = Class.new(Plyushkin::Test::Member) do
          hoards :login_date
        end

        member   = clazz.new
        property = member.login_date
        property.class.should == Plyushkin::Property
        property.should       == member.login_date
      end

      it 'should register a type for a hoarding property with persistence class' do
        clazz = Class.new(Plyushkin::Test::Member) do
          hoards :login_date
          hoards :geolocation, :type => Plyushkin::Test::CoordinateValue
        end

        clazz.plyushkin_model.registered_types[:login_date].should  == Plyushkin::StringValue
        clazz.plyushkin_model.registered_types[:geolocation].should == Plyushkin::Test::CoordinateValue
      end

      it 'should allow specifying value type' do
        clazz = Class.new(Plyushkin::Test::Member) do
          hoards :geolocation, :type => Plyushkin::Test::CoordinateValue
        end

        member = clazz.new
        property = member.geolocation
        property.value_type.should == Plyushkin::Test::CoordinateValue
      end

      it 'should use class name when setting up the service' do
        widget_one = Plyushkin::Test::WidgetOne.new
        widget_two = Plyushkin::Test::WidgetTwo.new

        widget_one.apples.create(:value => 1)
        widget_two.beans.create(:value => 2)

        widget_one.save!
        widget_two.save!

        widget_one.reload.apples.last.value.should == 1
        widget_two.reload.beans.last.value.should == 2
      end
    end

    describe 'after_create option' do
      it 'should call method specified by option after property create is called' do
        clazz = Class.new(Plyushkin::Test::Member) do
          attr_accessor :login_date_created_called
          hoards :login_date, :after_create => :login_date_created

          def login_date_created
            self.login_date_created_called = true
          end
        end

        member = clazz.new
        member.login_date.create :value => DateTime.now
        member.login_date_created_called.should be_true
      end

      it 'should call method specified by option after property create is called for the property named' do
        clazz = Class.new(Plyushkin::Test::Member) do
          attr_accessor :login_date_created_called, :other_prop_created_called

          hoards :login_date, :after_create => :login_date_created
          hoards :other_prop, :after_create => :other_prop_created

          def login_date_created
            self.login_date_created_called = true
          end

          def other_prop_created
            self.other_prop_created_called = true
          end
        end

        member = clazz.new
        member.other_prop.create :value => DateTime.now
        member.other_prop_created_called.should be_true
        member.login_date_created_called.should be_false
      end
    end

    describe 'ignore_unchanged_value option' do
      it 'should not add a value when ignore_unchanged_value is true and value is the same as the last value' do
        clazz = Class.new(Plyushkin::Test::Member) do
          hoards :login_date, :ignore_unchanged_values => true
        end

        member = clazz.new
        now = DateTime.now
        member.login_date.create(:value => now)
        member.login_date.create(:value => now)

        member.login_date.all.length.should == 1
      end

    end

    describe 'filter option' do
      it 'should filter results when a filter is specified' do
        clazz = Class.new(Plyushkin::Test::Member) do
          hoards :test_value, :filter => Proc.new{ |v| v.value > 5 }
        end

        member = clazz.new
        member.test_value.create(:value => 3)
        value = member.test_value.create(:value => 9)

        member.test_value.all.should == [ value ]
      end

      it 'should filter results when a filter is specified as a symbol' do
        clazz = Class.new(Plyushkin::Test::Member) do
          hoards :test_value, :filter => :filter_by

          def filter_by(value)
            value.value > 5
          end
        end

        member = clazz.new
        member.test_value.create(:value => 3)
        value = member.test_value.create(:value => 9)

        member.test_value.all.should == [ value ]
      end
    end

    describe 'class level filter for plyushkin' do
      it 'should filter all hoards if no filter is specified' do
        clazz = Class.new(Plyushkin::Test::Member) do
          filter_hoards_by :filter_by
          hoards :test_value
          hoards :bacon

          def filter_by(value)
            value.value > 5
          end
        end

        member = clazz.new
        member.test_value.create(:value => 3)
        value = member.test_value.create(:value => 9)

        member.test_value.all.should == [ value ]

        member.bacon.create(:value => 4)
        member.bacon.all.should == []
      end

      it 'should filter all hoards if no filter is specified' do
        clazz = Class.new(Plyushkin::Test::Member) do
          hoards :test_value
          hoards :bacon
          filter_hoards_by :filter_by

          def filter_by(value)
            value.value > 5
          end
        end

        member = clazz.new
        member.test_value.create(:value => 3)
        value = member.test_value.create(:value => 9)

        member.test_value.all.should == [ value ]

        member.bacon.create(:value => 4)
        member.bacon.all.should == []
      end

      it 'filter should override class level filter' do 
        clazz = Class.new(Plyushkin::Test::Member) do
          filter_hoards_by :filter_by
          hoards :test_value
          hoards :bacon, :filter => Proc.new {|v| v.value == 4}

          def filter_by(value)
            value.value > 5
          end
        end

        member = clazz.new
        member.test_value.create(:value => 3)
        value = member.test_value.create(:value => 9)

        member.test_value.all.should == [ value ]

        bacon_value = member.bacon.create(:value => 4)
        member.bacon.all.should ==  [ bacon_value ]

      end

      it 'filter should override class level filter' do 
        clazz = Class.new(Plyushkin::Test::Member) do
          hoards :test_value
          hoards :bacon, :filter => Proc.new {|v| v.value == 4}
          filter_hoards_by :filter_by

          def filter_by(value)
            value.value > 5
          end
        end

        member = clazz.new
        member.test_value.create(:value => 3)
        value = member.test_value.create(:value => 9)

        member.test_value.all.should == [ value ]

        bacon_value = member.bacon.create(:value => 4)
        member.bacon.all.should ==  [ bacon_value ]

      end
    end

    describe '#validates' do
      it 'should not be valid if hoarding property is not valid' do
        clazz = Class.new(Plyushkin::Test::Member) do
          hoards :geolocation, :type => Plyushkin::Test::CoordinateValue
        end
        clazz.stub(:model_name).and_return(ActiveModel::Name.new(clazz, nil, "test"))

        member = clazz.new
        member.geolocation.create(:x => 5)
        member.should_not be_valid
        member.errors.messages[:geolocation].count.should == 1
      end
    end

    describe '#save' do
      let(:clazz) do
        clazz = Class.new(Plyushkin::Test::Member) do
          hoards :login_date, :type => Plyushkin::Test::DateValue
        end
      end

      it 'should load plyushkin persistence after find is called' do
        member1 = clazz.new
        now = DateTime.now
        member1.login_date.create(:value => now)
        member1.save!

        member2 = clazz.find(member1.id)
        member2.login_date.last.value.should === now
      end

      it 'should save hoarding property by id' do
        member1 = clazz.new
        now = DateTime.now
        later = DateTime.now + 5
        member1.login_date.create(:value => now)
        member1.save!

        member2 = clazz.new
        member2.login_date.create(:value => later)
        member2.save!
        
        member1.reload.login_date.last.value.should === now
        member2.reload.login_date.last.value.should === later
      end
    end

    describe '#reload' do
      let(:clazz) do
        clazz = Class.new(Plyushkin::Test::Member) do
          hoards :login_date, :type => Plyushkin::Test::DateValue
        end
      end

      it 'should reload new data from persisted store' do
        member = clazz.new
        now = DateTime.now
        member.login_date.create(:value => now)
        member.save!
        member.login_date.create(:value => now + 5)

        member.reload
        member.login_date.last.value.should === now
      end
    end
  end
end

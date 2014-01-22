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

        clazz.plyushkin_model.registered_types[:login_date].should be_nil
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

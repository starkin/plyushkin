require 'spec_helper'

describe ActiveRecord::Base do
  describe '##historical_property' do
    describe 'read' do
      it 'should return the same property instance when called multiple times' do
        clazz = Class.new(Member) do
          historical_property :histprop
        end

        member   = clazz.new
        property = member.histprop
        property.class.should == Elephant::Property
        property.should       == member.histprop
      end

      it 'should register a type for a historical property with persistence class' do
        clazz = Class.new(Member) do
          historical_property :histprop
          historical_property :coordinate, :type => Elephant::Test::CoordinateValue
        end

        clazz.elephant_model.registered_types[:histprop].should be_nil
        clazz.elephant_model.registered_types[:coordinate].should == Elephant::Test::CoordinateValue
      end

      it 'should allow specifying value type' do
        clazz = Class.new(Member) do
          historical_property :histprop, :type => Elephant::Test::CoordinateValue
        end

        member = clazz.new
        property = member.histprop
        property.value_type.should == Elephant::Test::CoordinateValue
      end
    end

    describe 'after_create option' do
      it 'should call method specified by option after property create is called' do
        clazz = Class.new(Member) do
          attr_accessor :histprop_created_called
          historical_property :histprop, :after_create => :histprop_created

          def histprop_created
            self.histprop_created_called = true
          end
        end

        member = clazz.new
        member.histprop.create :value => 5
        member.histprop_created_called.should be_true
      end

      it 'should call method specified by option after property create is called for the property named' do
        clazz = Class.new(Member) do
          attr_accessor :histprop_created_called, :other_prop_created_called

          historical_property :histprop,   :after_create => :histprop_created
          historical_property :other_prop, :after_create => :other_prop_created

          def histprop_created
            self.histprop_created_called = true
          end

          def other_prop_created
            self.other_prop_created_called = true
          end
        end

        member = clazz.new
        member.other_prop.create :value => 5
        member.other_prop_created_called.should be_true
        member.histprop_created_called.should be_false
      end
    end

    describe 'ignore_unchanged_value option' do
      it 'should not add a value when ignore_unchanged_value is true and value is the same as the last value' do
        clazz = Class.new(Member) do
          historical_property :histprop, :ignore_unchanged_values => true
        end

        member = clazz.new
        member.histprop.create(:value => 10)
        member.histprop.create(:value => 10)

        member.histprop.all.length.should == 1
      end

    end

    describe '#validates' do
      it 'should not be valid if historical property is not valid' do
        clazz = Class.new(Member) do
          historical_property :histprop, :type => Elephant::Test::CoordinateValue
        end
        clazz.stub(:model_name).and_return(ActiveModel::Name.new(clazz, nil, "test"))

        member = clazz.new
        member.histprop.create(:x => 5)
        member.should_not be_valid
        member.errors.messages[:histprop].count.should == 1
      end
    end

    describe '#save' do
      let(:clazz) do
        clazz = Class.new(Member) do
          historical_property :histprop
        end
      end

      it 'should load elephant persistence after find is called' do
        member1 = clazz.new
        member1.histprop.create(:value => 5)
        member1.save!

        member2 = clazz.find(member1.id)
        member2.histprop.last.value.should == 5
      end

      it 'should save historical property by id' do
        member1 = clazz.new
        member1.histprop.create(:value => 5)
        member1.save!

        member2 = clazz.new
        member2.histprop.create(:value => 10)
        member2.save!
        
        member1.reload.histprop.last.value.should == 5
        member2.reload.histprop.last.value.should == 10
      end
    end

  end
end

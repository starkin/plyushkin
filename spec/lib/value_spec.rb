require 'spec_helper'

describe Plyushkin::StringValue do
  describe '#new' do
    it 'should allow storing an integer' do
      val = Plyushkin::StringValue.new(:value => 5)
      val.value.should == 5
    end

    it 'should allow storing a string' do
      val = Plyushkin::StringValue.new(:value => 'test')
      val.value.should == 'test'
    end

    it 'should use current if not specified' do
      Timecop.freeze do
        val = Plyushkin::StringValue.new(:value => 5)
        val.date.should == DateTime.current
      end
    end

    it 'should use provided date if specified' do
      date = DateTime.new(2013, 12, 20)
      val  = Plyushkin::StringValue.new(:value => 5, :date => date)
      val.date.should == date
    end
  end

end


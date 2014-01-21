require 'spec_helper'

describe Plyushkin::Persistence do
  let(:service) do
    service = Plyushkin::Service::Stub.new
    service.put(1,
      { :name   => [{ :value => 5 }] ,
        :weight => [{ :value => 150 }],
        :udt    => [{ :x => 10, :y => 20 }]
      }.to_json)
    service
  end

  let(:model) do
    m = Plyushkin::Model.new(service)
    m.register(:name,   Plyushkin::SimpleValue)
    m.register(:weight, Plyushkin::SimpleValue)
    m.register(:udt,    Plyushkin::Test::CoordinateValue)
    m
  end

  let(:persistence) do
    p = Plyushkin::Persistence.new(model)
    p.load(1)
    p
  end

  describe '#properties' do

    it 'should allow access to properties' do
      persistence.properties.length.should == 3
    end
  end

  describe '#save' do
    it 'should save to source that load uses' do
      persistence.properties[:name].create(:value => 2)
      persistence.save(1)
      persistence.load(1)
      persistence.properties[:name].last.value.should == 2
    end
  end

  describe '#load' do
    it 'should parse json into an hash of properties' do
      persistence.load(1)
      property = persistence.properties[:name]
      property.class.should == Plyushkin::Property
      property.last.value.should == 5
    end

    it 'should parse json for a user-defined type' do
      persistence.load(1)
      property = persistence.properties[:udt]
      property.last.x.should == 10
      property.last.y.should == 20
    end

    it 'should parse all history for a property' do
      service.put(1,
        {
          :name => [
            { :value => 5,  :date => DateTime.now - 2.days },
            { :value => 10, :date => DateTime.now - 3.days }
          ]
      }.to_json)

      property = persistence.properties[:name]
      property.all.length.should == 2
      property.all[0].value.should == 10
      property.all[1].value.should == 5
    end

    it "should add an empty array for a property that isn't returned from service" do
      model.register(:missing_property, Plyushkin::SimpleValue)
      persistence.properties[:missing_property].all.should == []
    end
  end
end

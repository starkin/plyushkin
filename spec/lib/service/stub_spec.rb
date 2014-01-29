require 'spec_helper'

describe Plyushkin::Service::Stub do
  let (:service) { Plyushkin::Service::Stub.new }
  let(:document) do
    {
      "weight" => [ {"value" => "5"} ]
    }
  end

  describe "#get" do
    it 'should get data' do
      service.put("widget", 14, document)
      service.get("widget", 14).should == document
    end
  end
end

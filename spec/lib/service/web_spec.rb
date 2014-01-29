require 'spec_helper'

describe Plyushkin::Service::Web do
  let(:document) do
    {
      "weight" => [ {"value" => "5"} ]
    }
  end

  describe '#get' do
    it 'should get json payload from service' do
      stub_request(:get, 'http://plyushkin.com/widget/2').to_return(
        :body => document.to_json)
      service = Plyushkin::Service::Web.new(:url => "http://plyushkin.com")
      service.get("widget", 2).should == document
    end
  end

  describe '#put' do
    it 'should send json payload' do
      stub_request(:put, 'http://plyushkin.com/widget/2').
        with(:body => document.to_json).
        to_return(:status => 200)

      service = Plyushkin::Service::Web.new(:url => "http://plyushkin.com")
      service.put("widget", 2, document)
    end
  end
end

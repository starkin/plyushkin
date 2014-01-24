require 'spec_helper'

describe Plyushkin::Service::Web do
  describe '#get' do
    let(:document) do
      {
        "weight" => [ {"value" => "5"} ]
      }
    end

    it 'should get json payload from service' do
      stub_request(:get, 'http://plyushkin.com/2').to_return(
        :body => document.to_json)
      service = Plyushkin::Service::Web.new
      service.url = "http://plyushkin.com"
      service.get(2).should == document
    end
  end
end

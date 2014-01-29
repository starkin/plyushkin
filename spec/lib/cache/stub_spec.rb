require 'spec_helper'

describe Plyushkin::Cache::Stub do
  let (:cache) { Plyushkin::Cache::Stub.new }

  describe "#write" do
    it "should write values to the cache" do
      cache.write("key", "value")
      cache.read("key").should == "value"
    end
  end

end

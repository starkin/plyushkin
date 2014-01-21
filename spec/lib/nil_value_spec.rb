require 'spec_helper'

describe Plyushkin::NilValue do
  it "should return nil for everything" do
    n = Plyushkin::NilValue.new
    n.steve_sucks.should be_nil
    n.apple.should be_nil
    n.value.should be_nil
    n.date.should be_nil
  end
end

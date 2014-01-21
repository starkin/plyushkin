require 'spec_helper'

describe Elephant::NilValue do
  it "should return nil for everything" do
    n = Elephant::NilValue.new
    n.steve_sucks.should be_nil
    n.apple.should be_nil
    n.value.should be_nil
    n.date.should be_nil
  end
end

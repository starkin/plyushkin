require 'spec_helper'

describe Plyushkin::Model do
  describe '#initialize' do
    it 'should raise an error if no service is provided' do
      expect {Plyushkin::Model.new(nil, 'name', nil)}
        .to raise_error(Plyushkin::Error, /Service cannot be nil/)
    end
  end
end

module Plyushkin::Service
  class << self
    attr_accessor :service
  end
end

require File.dirname(File.expand_path(__FILE__)) + "/service/stub"
require File.dirname(File.expand_path(__FILE__)) + "/service/web"


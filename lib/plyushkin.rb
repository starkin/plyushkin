require "plyushkin/version"

module Elephant; end
path = File.dirname(File.expand_path(__FILE__)) 
require path + "/elephant/lib/base_value"
require path + "/elephant/lib/simple_value"
require path + "/elephant/lib/nil_value"
require path + "/elephant/lib/property"
require path + "/elephant/lib/model"
require path + "/elephant/lib/service"
require path + "/elephant/lib/persistence"
require path + "/elephant/lib/validators/presence"
require path + "/elephant/lib/core_ext/active_record_base"

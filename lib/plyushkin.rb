require "plyushkin/version"

module Plyushkin; end
path = File.dirname(File.expand_path(__FILE__)) 
require path + "/plyushkin/lib/base_value"
require path + "/plyushkin/lib/simple_value"
require path + "/plyushkin/lib/nil_value"
require path + "/plyushkin/lib/property"
require path + "/plyushkin/lib/model"
require path + "/plyushkin/lib/service"
require path + "/plyushkin/lib/persistence"
require path + "/plyushkin/lib/validators/presence"
require path + "/plyushkin/lib/core_ext/active_record_base"

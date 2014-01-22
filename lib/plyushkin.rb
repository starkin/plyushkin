require "plyushkin/version"
require "active_record"

module Plyushkin; end
path = File.dirname(File.expand_path(__FILE__)) 
require path + "/plyushkin/base_value"
require path + "/plyushkin/string_value"
require path + "/plyushkin/nil_value"
require path + "/plyushkin/property"
require path + "/plyushkin/model"
require path + "/plyushkin/service"
require path + "/plyushkin/persistence"
require path + "/plyushkin/validators/presence"
require path + "/plyushkin/core_ext/plyushkin_extensions"
require path + "/plyushkin/core_ext/active_record_base"

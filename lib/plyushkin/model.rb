class Plyushkin::Model
  attr_reader :service, :name

  def initialize(service, name)
    @service          = service
    @types            = {}
    @ignore_unchanged_values = {}
    @callbacks        = {}
    @name = name
  end

  def register(name, type, opts={})
    @types[name]            = type 
    @ignore_unchanged_values[name] = opts[:ignore_unchanged_values] 
  end

  def register_callback(name, callback, method_sym)
    @callbacks[name] = { callback => method_sym }
  end

  def registered_types
    @types.dup
  end

  def callbacks
    @callbacks.dup
  end

  def ignore_unchanged_values
    @ignore_unchanged_values.dup
  end
end

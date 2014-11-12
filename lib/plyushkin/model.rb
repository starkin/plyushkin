class Plyushkin::Model
  attr_reader :service, :name, :cache

  def initialize(service, name, cache)
    raise Plyushkin::Error.new <<-ERROR unless service
    Service cannot be nil.  Set Plyushkin::Service.service to a service instance in an initializer.
    ERROR

    @service                 = service
    @types                   = {}
    @ignore_unchanged_values = {}
    @callbacks               = {}
    @filters                 = {}
    @name                    = name
    @cache                   = cache
  end

  def register(name, type, opts = {})
    @types[name]                   = type
    @ignore_unchanged_values[name] = opts[:ignore_unchanged_values]
  end

  def register_callback(name, callback, method_sym)
    @callbacks[name] = { callback => method_sym }
  end

  def register_filter(name, method_sym)
    @filters[name] = method_sym
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

  def filters
    @filters.dup
  end
end

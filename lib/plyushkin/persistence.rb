class Plyushkin::Persistence

  def initialize(model)
    @model = model
    @callbacks = {}
  end

  def properties
    @properties
  end

  def save(id)
    hash = {}
    (@properties || {}).each do |name, property|
      hash[name] = [property.value_hashes]
    end
    model.service.put(id, hash.to_json)
  end

  def load(id)
    @properties = {}
    model.service.get(id).each do |name, values| 
      property = Plyushkin::Property.build(name, model.registered_types[name.to_sym], values,
                                         :callbacks               => @callbacks[name.to_sym],
                                         :ignore_unchanged_values => @model.ignore_unchanged_values[name.to_sym] )
      @properties[name.to_sym] = property
    end
    add_missing_properties
  end

  def register_callback(name, callback, &block)
    @callbacks[name] = { callback => block }
  end

  private 
  def model
    @model
  end

  def add_missing_properties
    (model.registered_types.keys - @properties.keys).each do |name|
      property = Plyushkin::Property.new(name, 
                                        :type                    => model.registered_types[name],
                                        :callbacks               => @callbacks[name],
                                        :ignore_unchanged_values => @model.ignore_unchanged_values[name])
      @properties[name] = property
    end
  end

end

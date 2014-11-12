module PlyushkinExtensions
  def reload(options=nil)
    plyushkin.load(id)
    super
  end

  def plyushkin
    @plyushkin ||= Plyushkin::Persistence.new(self.class.plyushkin_model)
  end

  def load_plyushkin
    self.class.plyushkin_model.callbacks.each do |name,callbacks|
      callbacks.each do |callback, handler|
        plyushkin.register_callback(name, callback) do
          (handler && handler.is_a?(Symbol)) ? send(handler) : handler.call
        end
      end
    end

    self.class.plyushkin_model.registered_types.each do |name, type|
      filter = self.class.plyushkin_model.filters[name] || self.class.plyushkin_model.hoarding_filter
      plyushkin.register_filter(name) do |value|
        (filter && filter.is_a?(Symbol)) ? send(filter, value) : filter.call(value)
      end if filter
    end

    plyushkin.load(id)
  end

  def save_plyushkin
    plyushkin.save(id)
  end
end

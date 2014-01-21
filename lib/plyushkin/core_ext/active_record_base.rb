ActiveRecord::Base.instance_eval do
  def historical_property(name, opts = {})
    initialize_plyushkin

    define_method(name) do
      plyushkin.properties[name]
    end
    validates name, :plyushkin => true

    plyushkin_model.register(name, opts[:type], opts)
    plyushkin_model.register_callback(name, :after_create, opts[:after_create]) if opts[:after_create]
  end

  def initialize_plyushkin
    class << self 
      def plyushkin_model
        @plyushkin_model ||= Plyushkin::Model.new(Plyushkin::Service::Stub.new)
      end
    end

    after_initialize :load_plyushkin
    after_save :save_plyushkin

    define_method(:plyushkin) do
      @plyushkin ||= Plyushkin::Persistence.new(self.class.plyushkin_model)
    end

    define_method(:load_plyushkin) do
      self.class.plyushkin_model.callbacks.each do |name,callbacks|
        callbacks.each do |callback, handler|
          plyushkin.register_callback(name, callback) do
            (handler && handler.is_a?(Symbol)) ? send(handler) : handler.call
          end
        end
      end

      plyushkin.load(id)
    end

    define_method(:save_plyushkin) do
      plyushkin.save(id)
    end
  end
end


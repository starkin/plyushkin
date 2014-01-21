ActiveRecord::Base.instance_eval do
  def historical_property(name, opts = {})
    initialize_elephant

    define_method(name) do
      elephant.properties[name]
    end
    validates name, :elephant => true

    elephant_model.register(name, opts[:type], opts)
    elephant_model.register_callback(name, :after_create, opts[:after_create]) if opts[:after_create]
  end

  def initialize_elephant
    class << self 
      def elephant_model
        @elephant_model ||= Elephant::Model.new(Elephant::Service::Stub.new)
      end
    end

    after_initialize :load_elephant
    after_save :save_elephant

    define_method(:elephant) do
      @elephant ||= Elephant::Persistence.new(self.class.elephant_model)
    end

    define_method(:load_elephant) do
      self.class.elephant_model.callbacks.each do |name,callbacks|
        callbacks.each do |callback, handler|
          elephant.register_callback(name, callback) do
            (handler && handler.is_a?(Symbol)) ? send(handler) : handler.call
          end
        end
      end

      elephant.load(id)
    end

    define_method(:save_elephant) do
      elephant.save(id)
    end
  end
end


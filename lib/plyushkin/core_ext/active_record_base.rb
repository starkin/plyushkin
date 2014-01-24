ActiveRecord::Base.instance_eval do
  def hoards(name, opts = {})
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
        @plyushkin_model ||= Plyushkin::Model.new(Plyushkin::Service.service)
      end
    end

    include PlyushkinExtensions

    after_initialize :load_plyushkin
    after_save :save_plyushkin
  end
end


ActiveRecord::Base.instance_eval do
  def hoards(name, opts = {})
    initialize_plyushkin

    define_method(name) do
      plyushkin.properties[name]
    end
    validates name, :plyushkin => true

    plyushkin_model.register(name, opts[:type] || Plyushkin::StringValue, opts)
    plyushkin_model.register_callback(name, :after_create, opts[:after_create]) if opts[:after_create]
    plyushkin_model.register_filter(name, opts[:default_filter]) if opts[:default_filter]
  end

  def filter_hoards_by(filter)
    initialize_plyushkin

    plyushkin_model.hoarding_filter = filter
  end

  def initialize_plyushkin
    class << self
      def plyushkin_model
        model_name = name ? name.parameterize : "record"
        @plyushkin_model ||= Plyushkin::Model.new(Plyushkin::Service.service, model_name, Plyushkin::Cache.cache)
      end
    end

    include PlyushkinExtensions

    after_initialize :load_plyushkin
    after_save :save_plyushkin
  end
end


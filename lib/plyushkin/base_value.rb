class Plyushkin::BaseValue
  include ActiveModel::Validations

  def initialize(attr={})
    attr   = attr.dup
    @date  = attr.delete(:date) || DateTime.current
    attr.each do |k,v|
      send("#{k}=", v) if respond_to?("#{k}=")
    end
  end

  def self.persisted_attr(*attributes)
    opts = attributes.last.is_a?(Hash) ? attributes.pop : {}
    names = attributes
    formatter = opts[:formatter]

    persisted_attributes.concat(names)
    attr_writer *names
    names.each do |name|
      define_method(name) do
        value = instance_variable_get("@#{name}")
        if formatter
          send(formatter, value)
        else
          value
        end
      end
    end
  end

  def self.persisted_attributes
    if self.superclass == Object
      @persisted_attributes ||= []
    else
      @persisted_attributes ||= superclass.persisted_attributes.dup
    end
  end

 persisted_attr :date, :formatter => :to_date
  validates_each :date do |record, attr_name, value|
    record.errors.add(attr_name, "cannot be in the future") unless value < DateTime.now
  end

  def equal_value?(other)
    self.class.persisted_attributes.each do |attribute|
      return false if attribute != :date && send(attribute) != other.send(attribute)
    end
    true
  end

  def to_i(value)
    value.to_i
  end

  def to_date(value)
    value.is_a?(String) ? DateTime.parse(value) : value
  end

end

class Plyushkin::Property
  include ActiveModel::Validations

  DEFAULT_CALLBACK = lambda{}

  attr_reader :name

  validate do |property|
    last.errors.full_messages.each do |message|
      errors[:base] << "#{name.camelize}: #{message}"
    end unless last.valid?
  end

  def initialize(name, opts={})
    @values           = []
    @value_type       = opts[:type]
    @callbacks        = opts[:callbacks]
    @ignore_unchanged_values = opts[:ignore_unchanged_values]
    @name             = name.to_s
  end

  def create(attr={})
    value = value_type.new(attr)
    if @ignore_unchanged_values
      last = @values.last
      return last if last && last.equal_value?(value)
    end

    @values.insert(insert_position(value.date), value)
    trigger_callback(:after_create)
    value
  end

  def trigger_callback(sym)
    @callbacks.fetch(sym, DEFAULT_CALLBACK).call if @callbacks
  end

  def all
    @values
  end

  def last
    @values.last || Plyushkin::NilValue.new
  end

  def empty?
    @values.empty?
  end

  def insert_position(datetime)
    index = @values.rindex{|v| v.date < datetime}
    index.nil? ? 0 : index + 1
  end

  def value_type
    @value_type ||= Plyushkin::StringValue
  end

  def self.build(name, type, values, opts={})
    opts[:type] = type
    Plyushkin::Property.new(name, opts).tap do |p|
      values.each { |value| p.create(value) }
    end
  end

  def value_hashes
    value_hashes = {}
    all.each do |value|
      value_type.persisted_attributes.each do |attr|
        value_hashes[attr] = value.send(attr) 
      end
    end

    value_hashes
  end
end

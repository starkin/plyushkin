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
    #write a spec for this option
    ignore_invalid = attr.delete(:ignore_invalid)
    value = value_type.new(attr)
    if @ignore_unchanged_values
      last = @values.last
      return last if last && last.equal_value?(value)
    end

    return if !value.valid? && ignore_invalid

    @values.insert(insert_position(value.date), value)
    #write a spec for this option
    trigger_callback(:after_create) if value.new_record?

    @dirty = true
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

  def self.load(name, type, values, opts={})
    opts[:type] = type
    prop = Plyushkin::Property.new(name, opts).tap do |p|
      values.each { |value| load_value(p, value) }
    end

    prop
  end

  def value_hashes
    all_value_hashes = []
    all.each do |value|
      value_hash = {}
      value_type.persisted_attributes.each do |attr|
        value_hash[attr] = value.send(attr) 
      end
      all_value_hashes << value_hash
    end

    all_value_hashes 
  end

  def nil?
    last.is_a?(Plyushkin::NilValue)
  end

  def dirty?
    @dirty
  end

  def mark_persisted
    @dirty = false
    all.each(&:mark_persisted)
  end

  private 

  def self.load_value(property, value)
    property.create(value.merge(:new_record => false)) 
  end

end

class ElephantValidator < ActiveModel::EachValidator
  def validate_each(record, attr_name, property)
    record.errors.add(attr_name, :valid, options) unless property.valid?
  end
end

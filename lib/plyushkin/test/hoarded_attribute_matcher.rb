class Plyushkin::Test::HoardedAttributeMatcher
  def initialize(attribute)
    @attribute = attribute
  end

  def matches?(subject)
    subject.class.plyushkin_model.registered_types.keys.include?(@attribute)
  end
end

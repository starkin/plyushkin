class Plyushkin::Test::WithFormatMatcher
  def initialize(attr_name, formatter)
    @attr_name, @formatter = attr_name, formatter
  end

  def match(subject)
    subject.class.formatters[@attr_name] == @formatter
  end

  def failure_message
    "Plyushkin: attribute #{@attr_name} is not formatting with #{@formatter}"
  end
end

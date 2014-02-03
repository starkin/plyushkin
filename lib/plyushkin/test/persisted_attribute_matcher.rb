class Plyushkin::Test::PersistedAttributeMatcher < Plyushkin::Test::MatcherBase

  def initialize(attr_name)
    @attr_name = attr_name
  end

  def with_format(formatter)
    matchers << WithFormatMatcher.new(@attr_name, formatter)
    self
  end

  def matches?(subject)
    @failure_message          = "Plyushkin: no persisted attribute with name '#{@attr_name}'" unless subject.class.persisted_attributes.include?(@attr_name)
    @negative_failure_message = "Plyushkin: persisted attribute with name '#{@attr_name}' exists" unless subject.class.persisted_attributes.include?(@attr_name)
    super
  end

  class WithFormatMatcher
    def initialize(attr_name, formatter)
      @attr_name, @formatter = attr_name, formatter
    end

    def match(subject)
      subject.class.formatters[@attr_name] == @formatter
    end

    def failure_message
      "Plyushkin: attribute #{@attr_name} is not formatting with #{@formatter}"
    end

    def negative_failure_message
      "Plyushkin: attribute #{@attr_name} is formatting with #{@formatter}"
    end
  end
end


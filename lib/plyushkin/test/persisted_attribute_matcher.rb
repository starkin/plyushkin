class Plyushkin::Test::PersistedAttributeMatcher

  def initialize(attr_name)
    @attr_name = attr_name
    @matchers = []
  end

  def with_format(formatter)
    @matchers << Plyushkin::Test::WithFormatMatcher.new(@attr_name, formatter)
    self
  end

  def matches?(subject)
    @subject = subject
    @failure_message = "Plyushkin: no persisted attribute with name '#{@attr_name}'" unless @subject.class.persisted_attributes.include?(@attr_name)
    @matchers.each do |m| 
      unless m.match(subject) 
        @failure_message = m.failure_message 
        break
      end
    end
    return @failure_message.nil?
  end

  def failure_message
    @failure_message
  end

  def description
    "Description not set"
  end
end

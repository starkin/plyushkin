class Plyushkin::Test::HoardedAttributeMatcher < Plyushkin::Test::MatcherBase
  def initialize(attribute)
    @attribute = attribute
  end

  def of_type(type)
    matchers << OfTypeMatcher.new(@attribute, type)
    self
  end

  def and_ignore_unchanged_values
    matchers << IgnoreUnchangedMatcher.new(@attribute)
    self
  end

  def and_after_create_call(sym)
    matchers << CallbackMatcher.new(@attribute, sym)
    self
  end

  def matches?(subject)
    unless subject.class.plyushkin_model.registered_types.keys.include?(@attribute)
      @failure_message          = "Plyushkin: does not hoard attribute #{@attribute}"
      @negative_failure_message = "Plyushkin: hoards attribute #{@attribute}"
    end
    super
  end

  class OfTypeMatcher
    def initialize(attr_name, type)
      @attr_name, @type = attr_name, type
    end

    def match(subject)
      subject.class.plyushkin_model.registered_types[@attr_name] == @type
    end

    def failure_message
      message(false)
    end

    def negative_failure_message
      message(true)
    end

    private
    def message(negate)
      "Plyushkin: Hoarded attribute #{@attr_name} is #{negate ? "" : "not"} of type #{@type}"
    end
  end

  class IgnoreUnchangedMatcher
    def initialize(attr_name)
      @attr_name = attr_name
    end

    def match(subject)
      subject.class.plyushkin_model.ignore_unchanged_values[@attr_name]
    end

    def failure_message
      message(true)
    end

    def negative_failure_message
      message(false)
    end

    def message(negate)
      "Plyushkin:: Hoarded attribute #{@attr_name} #{negate ? "ignores" : "does not ignore"} unchanged values"
    end
  end

  class CallbackMatcher
    def initialize(attr_name, callback)
      @attr_name, @callback = attr_name, callback
    end

    def match(subject)
      callbacks = subject.class.plyushkin_model.callbacks[@attr_name]
      callbacks && (callbacks[:after_create] == @callback)
    end

    def failure_message
      message(true)
    end

    def negative_failure_message
      message(false)
    end

    def message(negate)
      "Plyushkin:: Hoarded attribute #{@attr_name} #{negate ? "does not callback" : "calls back"} #{@callback}"
    end
  end
end

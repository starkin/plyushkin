module Plyushkin::Test
  class MatcherBase
    def matchers
      @matchers ||= []
    end

    def matches?(subject)
      matchers.each do |m| 
        unless m.match(subject) 
          @failure_message          = m.failure_message 
          @negative_failure_message = m.negative_failure_message 
          break
        end
      end
      return @failure_message.nil?
    end

    def failure_message
      @failure_message
    end

    def negative_failure_message
      @negative_failure_message
    end

    def description
      "Description not set"
    end
  end
end

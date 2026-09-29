# frozen_string_literal: true

module PrettyTree
  class Formatter
    def label(value, max_width: nil)
      raise NotImplementedError, "#{self.class} must implement #label"
    end
  end
end

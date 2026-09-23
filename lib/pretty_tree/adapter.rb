# frozen_string_literal: true

module PrettyTree
  class Adapter
    def value(node)
      raise NotImplementedError, "#{self.class} must implement #value"
    end

    def children(node)
      raise NotImplementedError, "#{self.class} must implement #children"
    end
  end
end

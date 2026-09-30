# frozen_string_literal: true

# Reads a tree node's value and children.
#
# Adapters are never called with nil: the renderer treats a nil node as an empty
# slot and does not ask the adapter about it.
#
# #value(node)    - anything the Formatter can turn into a label.
# #children(node) - responds to #each, never nil. Yields the child nodes in
#                   order, with nil marking an empty slot.
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

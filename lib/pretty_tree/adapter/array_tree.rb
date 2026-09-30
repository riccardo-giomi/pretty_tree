# frozen_string_literal: true

require_relative "../adapter"

# Adapter for trees represented as nested arrays.
#
# Example, binary tree:
#
#        c
#      /   \
#     b     d
#   /      /  \
# a       e    f
#
# ["c",
#   ["b",
#     ["a", nil, nil]
#   ],
#   ["d",
#     ["e", nil, nil],
#     ["f", nil, nil]
#   ]
# ]
#
module PrettyTree
  class Adapter
    class ArrayTree < PrettyTree::Adapter
      def validate(node)
        unless node.is_a?(Array) && !node.empty?
          got = node.is_a?(Array) ? "[]" : node.class.name
          raise PrettyTree::Error, "invalid tree node, expected non-empty Array, got #{got}"
        end
      end

      def value(node)
        validate(node)
        node.first
      end

      def children(node)
        validate(node)
        children = node[1...]

        children.each { |node| validate(node) unless node.nil? }

        children
      end
    end
  end
end

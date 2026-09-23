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
      def value(node) = node.first

      def children(node) = node[1...]
    end
  end
end

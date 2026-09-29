# frozen_string_literal: true

require_relative "layout"

module PrettyTree
  class Renderer
    LABEL_WIDTH = 12

    def initialize(adapter:, formatter:, max_width: LABEL_WIDTH)
      @adapter = adapter
      @formatter = formatter
      @max_width = max_width
    end

    def call(tree) = box_for(tree).lines.join("\n")

    def box_for(node, parent_arity: 1, position: 0)
      return Layout.empty_box(parent_arity:) if node.nil?

      label = @formatter.label(@adapter.value(node), max_width: @max_width)
      children = @adapter.children(node)
      # Visit all children, merge getting back from the recursion
      child_boxes = children.each_with_index.map do |node, i|
        box_for(node, parent_arity: children.size, position: i)
      end

      Layout.node_box(label, child_boxes, parent_arity:, position:)
    end
  end
end

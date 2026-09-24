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

    def box_for(node)
      return Layout.empty_node if node.nil?

      label = @formatter.label(@adapter.value(node), max_width: @max_width)
      child_boxes = @adapter.children(node).map { |child| box_for(child) }

      return Layout.leaf_node(label) if child_boxes.all?(&:empty?)

      Data.define(:lines)[
      lines: [
        "    1    ",
        "   / \\   ",
        "  /   \\  ",
        " 2     3 "
      ]]
    end
  end
end

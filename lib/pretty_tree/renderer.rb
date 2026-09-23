# frozen_string_literal: true

module PrettyTree
  class Renderer
    LABEL_WIDTH = 12

    def initialize(adapter:, formatter:, max_width: LABEL_WIDTH)
      @adapter = adapter
      @formatter = formatter
      @max_width = max_width
    end

    def box_for(node)
      return [""] if node.nil?

      label = @formatter.label(@adapter.value(node), max_width: @max_width)
      _children = @adapter.children(node)

      [label]
    end
  end
end

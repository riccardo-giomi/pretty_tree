# frozen_string_literal: true

require_relative "box"

module PrettyTree
  module Layout
    GAP = 1
    MIN_LEAF_SIZE = 3 # Required to allow space for connector symbols
    MIN_BINARY_LEAF_SIZE = 5 # Binary leaves require more space for connector symbols

    def self.pad_label(label, arity:) = label.to_s.center((arity == 2) ? MIN_BINARY_LEAF_SIZE : MIN_LEAF_SIZE)

    def self.empty_box(arity:) = Box.empty(pad_label(nil, arity:))

    def self.leaf_box(label, arity:) = Box.leaf(pad_label(label, arity:))

    def self.node_box(label, child_boxes, arity:)
      return leaf_box(label, arity:) if child_boxes.all?(&:empty?)

      return Box.new(lines: [" 1 ", " | ", " | ", " 2 "], width: 3, anchor: 1, empty: false) if child_boxes.size == 1

      layout = layout_for(child_boxes)

      lines, width, offsets = layout.merge

      anchor = layout.label_anchor(offsets)

      label_line = layout.render_label_line(label, width, anchor)
      connector_lines = layout.render_connector_lines(label, anchor, child_boxes, offsets, width)

      new_lines = [label_line] + connector_lines + lines
      Box.new(lines: new_lines, width:, anchor:, empty: false)
    end

    def self.layout_for(boxes)
      case boxes.size
      when 1
        Unary
      when 2
        Binary
      when 3
        Ternary
      else
        Generic
      end.new(boxes)
    end

    class Base
      def initialize(boxes)
        @boxes = boxes
      end

      def merge
        height = @boxes.map(&:height).max

        lines = Array.new(height) { "" }
        offsets = []
        @boxes.each_with_index do |box, i|
          offsets << lines.first.length + box.anchor

          padded_lines(box, height).each_with_index do |line, j|
            lines[j] += line
            # Do not gap the last box
            lines[j] += " " * GAP unless i == @boxes.size - 1
          end
        end

        [lines, lines.first.length, offsets]
      end

      def padded_lines(box, height)
        return box.lines if box.height == height

        padding = Array.new(height - box.height) { " " * box.width }
        box.lines + padding
      end

      def render_label_line(label, width, anchor)
        label_start = anchor - label.length / 2
        line = " " * width
        line[label_start, label.length] = label
        line
      end
    end

    class Unary < Base
      # Spoiler for later dev loops
      # def label_anchor(offsets)
      #   offsets.first
      # end
    end

    class Binary < Base
      def label_anchor(offsets)
        (offsets.last - offsets.first) - 1
      end

      def render_connector_lines(parent_label, parent_anchor, boxes, offsets, width)
        lines = Array.new(2) { " " * width }

        unless boxes.first.empty?
          lines = render_left_branch(lines, parent_label, parent_anchor, offsets)
        end
        unless boxes.last.empty?
          lines = render_right_branch(lines, parent_label, parent_anchor, offsets)
        end

        lines
      end

      def render_left_branch(lines, parent_label, parent_anchor, offsets)
        anchor = offsets.first
        first_parent_label_char = parent_anchor - parent_label.length / 2
        labels_distance = first_parent_label_char - (anchor + 2)
        anchors_distance = parent_anchor - (anchor + 2)

        if labels_distance > 1
          lines[0][anchor + 2, anchors_distance + 1] = "_" * anchors_distance + "|"
        else
          lines[0][anchor + 2] = "/"
        end
        lines[1][anchor + 1] = "/"

        lines
      end

      def render_right_branch(lines, parent_label, parent_anchor, offsets)
        anchor = offsets.last
        last_parent_label_char = parent_anchor + parent_label.length / 2
        anchors_distance = anchor - 2 - parent_anchor
        labels_distance = (anchor - 2) - last_parent_label_char
        if labels_distance > 1
          lines[0][parent_anchor, anchors_distance + 1] = "|" + "_" * anchors_distance
        else
          lines[0][anchor - 2] = "\\"
        end
        lines[1][anchor - 1] = "\\"

        lines
      end
    end

    class Ternary < Base
      # Spoiler for later dev loops
      #   def label_anchor(offsets)
      #     offsets[1]
      #   end
    end

    class Generic < Base
      # Spoiler for later dev loops
      #   def label_anchor(offsets)
      #     (offsets.last - offsets.first) - 1
      #   end
    end
  end
end

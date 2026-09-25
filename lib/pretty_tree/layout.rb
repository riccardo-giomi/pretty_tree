# frozen_string_literal: true

require_relative "box"

module PrettyTree
  module Layout
    GAP = 1
    MIN_LEAF_SIZE = 3 # Required to allow space for connector symbols
    MIN_BINARY_LEAF_SIZE = 5 # Binary leaves require more space for connector symbols

    def self.pad_label(label, parent_arity:) = label.to_s.center((parent_arity == 2) ? MIN_BINARY_LEAF_SIZE : MIN_LEAF_SIZE)

    def self.empty_box(parent_arity:) = Box.empty(pad_label(nil, parent_arity:))

    def self.leaf_box(label, parent_arity:) = Box.leaf(pad_label(label, parent_arity:))

    def self.node_box(label, child_boxes, parent_arity:)
      return leaf_box(label, parent_arity:) if child_boxes.all?(&:empty?)

      label = pad_label(label, parent_arity:)
      layout = layout_for(child_boxes)

      lines, width, offsets = layout.merge

      anchor = layout.label_anchor(offsets)
      lines, width, offsets, anchor = layout.accommodate_parent_label(lines, width, offsets, anchor, label.length)

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

      # Ensures that the box created by merging the children subtrees is not
      # smaller than the parent label, including the fact that the label does not
      # start from the beginning of its line.
      def accommodate_parent_label(lines, width, offsets, anchor, label_length)
        label_left = label_length / 2
        label_right = label_length - label_left

        left_pad = [label_left - anchor, 0].max
        anchor += left_pad
        right_pad = [anchor + label_right - (width + left_pad), 0].max

        return [lines, width, offsets, anchor] if left_pad.zero? && right_pad.zero?

        lines = lines.map { |line| (" " * left_pad) + line + (" " * right_pad) }
        [lines, width + left_pad + right_pad, offsets.map { |o| o + left_pad }, anchor]
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

      def render_middle_branch(lines, anchor)
        lines[0][anchor] = "|"
        lines[1][anchor] = "|"

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

    class Unary < Base
      def label_anchor(offsets)
        offsets.first
      end

      def render_connector_lines(_parent_label, _parent_anchor, boxes, offsets, width)
        lines = Array.new(2) { " " * width }

        lines = render_middle_branch(lines, offsets.first) unless boxes.first.empty?

        lines
      end
    end

    class Binary < Base
      def label_anchor(offsets)
        (offsets.last - offsets.first) - 1
      end

      def render_connector_lines(parent_label, parent_anchor, boxes, offsets, width)
        lines = Array.new(2) { " " * width }

        lines = render_left_branch(lines, parent_label, parent_anchor, offsets) unless boxes.first.empty?
        lines = render_right_branch(lines, parent_label, parent_anchor, offsets) unless boxes.last.empty?

        lines
      end
    end

    class Ternary < Base
      def label_anchor(offsets)
        offsets[1]
      end

      def render_connector_lines(parent_label, parent_anchor, boxes, offsets, width)
        lines = Array.new(2) { " " * width }

        lines = render_left_branch(lines, parent_label, parent_anchor, offsets) unless boxes.first.empty?
        lines = render_middle_branch(lines, offsets[1]) unless boxes[1].empty?
        lines = render_right_branch(lines, parent_label, parent_anchor, offsets) unless boxes.last.empty?

        lines
      end
    end

    class Generic < Base
      # Spoiler for later dev loops
      #   def label_anchor(offsets)
      #     (offsets.last - offsets.first) - 1
      #   end
    end
  end
end

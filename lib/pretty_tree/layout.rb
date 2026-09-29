# frozen_string_literal: true

require_relative "box"

module PrettyTree
  module Layout
    GAP = 1

    def self.empty_box(parent_arity:)
      layout_class_for(parent_arity).empty_box
    end

    def self.node_box(label, child_boxes, parent_arity:, position:)
      return layout_class_for(parent_arity).leaf_box(label, position:) if child_boxes.all?(&:empty?)

      label = Base.pad_label(label)

      layout = layout_for(child_boxes)
      lines, width, offsets = layout.merge

      anchor = layout.label_anchor(offsets)
      lines, width, offsets, anchor = layout.accommodate_parent_label(lines, width, offsets, anchor, label.length)

      label_line = layout.render_label_line(label, width, anchor)
      connector_lines = layout.render_connector_lines(label, anchor, offsets, width)

      new_lines = [label_line] + connector_lines + lines
      Box.new(lines: new_lines, width:, anchor:, empty: false)
    end

    def self.layout_class_for(size)
      case size
      when 1
        Unary
      when 2
        Binary
      when 3
        Ternary
      else
        Generic
      end
    end

    def self.layout_for(boxes)
      layout_class_for(boxes.size).new(boxes)
    end

    class Base
      MIN_LEAF_SIZE = 3 # Required to allow space for connector symbols

      def self.pad_label(label) = label.to_s.center(MIN_LEAF_SIZE)

      def self.leaf_box(label, position:) = Box.leaf(pad_label(label))
      def self.empty_box = Box.empty(pad_label(nil))

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

      def render_connector_lines(_parent_label, _parent_anchor, offsets, width)
        lines = Array.new(2) { " " * width }

        lines = render_middle_branch(lines, offsets.first) unless @boxes.first.empty?

        lines
      end
    end

    class Binary < Base
      CONNECTOR_SPAN = 3
      MIN_ANCHORS_DISTANCE = 2 * CONNECTOR_SPAN

      # Binary leaves require more space for connector symbols
      def self.leaf_box(label, position:)
        padded = pad_label(label)
        return Box.leaf(padded + " ", anchor: padded.size / 2) if position == 0

        Box.leaf(" " + padded, anchor: padded.size / 2 + 1)
      end

      def self.empty_box = Box.empty("")

      def label_anchor(offsets)
        return offsets.last - CONNECTOR_SPAN if @boxes.first.empty?
        return offsets.first + CONNECTOR_SPAN if @boxes.last.empty?

        offsets.first + (offsets.last - offsets.first) / 2
      end

      def merge
        lines, width, offsets = super
        return [lines, width, offsets] if @boxes.any?(&:empty?)

        spread = MIN_ANCHORS_DISTANCE - (offsets.last - offsets.first)
        return [lines, width, offsets] unless spread.positive?

        lines = lines.map { |line| line.dup.insert(@boxes.first.width, " " * spread) }
        [lines, width + spread, [offsets.first, offsets.last + spread]]
      end

      def render_connector_lines(parent_label, parent_anchor, offsets, width)
        lines = Array.new(2) { " " * width }

        lines = render_left_branch(lines, parent_label, parent_anchor, offsets) unless @boxes.first.empty?
        lines = render_right_branch(lines, parent_label, parent_anchor, offsets) unless @boxes.last.empty?

        lines
      end
    end

    class Ternary < Base
      def label_anchor(offsets)
        offsets[1]
      end

      def render_connector_lines(parent_label, parent_anchor, offsets, width)
        lines = Array.new(2) { " " * width }

        lines = render_left_branch(lines, parent_label, parent_anchor, offsets) unless @boxes.first.empty?
        lines = render_middle_branch(lines, offsets[1]) unless @boxes[1].empty?
        lines = render_right_branch(lines, parent_label, parent_anchor, offsets) unless @boxes.last.empty?

        lines
      end
    end

    class Generic < Base
      def initialize(boxes)
        super(boxes.reject(&:empty?))
      end

      def label_anchor(offsets)
        middle_or_middle_right_index = offsets.size / 2
        middle_or_middle_right_offset = offsets[middle_or_middle_right_index]

        return middle_or_middle_right_offset if offsets.size.odd?

        middle_left_offset = offsets[middle_or_middle_right_index - 1]

        middle_left_offset + ((middle_or_middle_right_offset - middle_left_offset) / 2)
      end

      def render_connector_lines(parent_label, parent_anchor, offsets, width)
        lines = Array.new(2) { " " * width }

        return render_middle_branch(lines, offsets.first) if offsets.size == 1

        # Single line from (first adjusted anchor + 1) to (last adjusted anchor - 1)
        from = offsets.first + 1
        to = offsets.last
        lines[0][from...to] = "_" * (to - from)
        # With a single | breaking the line under the parent anchor
        lines[0][parent_anchor] = "|"

        # Second line is just a "|" over each adjusted anchor
        offsets.each do |offset|
          lines[1][offset] = "|"
        end

        lines
      end
    end
  end
end

# frozen_string_literal: true

# A rectangular block of text: some lines, all the same width, plus an `anchor
# column`. It represents a rendered sub-tree.
#
# The anchor column is the column (within that block) where the node's label is
# centered.
#
module PrettyTree
  # lines:   Array<String>, each exactly :width characters
  # anchor:  0-indexed column
  Box = Struct.new(:lines, :width, :anchor, :empty) do
    def self.leaf(label, anchor: label.size / 2, empty: false)
      new(lines: [label], width: label.size, anchor:, empty:)
    end

    # An empty box can still have a label if the layout renders it as empty
    # spaces for spacing.
    def self.empty(label, anchor: label.size / 2)
      leaf(label, anchor:, empty: true)
    end

    def height = lines.size
    def empty? = !!empty
  end
end

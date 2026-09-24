# frozen_string_literal: true

require_relative "box"

module PrettyTree
  module Layout
    MIN_LEAF_SIZE = 3 # Required to allow space for connector symbols

    def self.pad_label(label) = label.to_s.center(MIN_LEAF_SIZE)

    def self.empty_node = Box.empty(pad_label(nil))

    def self.leaf_node(label) = Box.leaf(pad_label(label))
  end
end

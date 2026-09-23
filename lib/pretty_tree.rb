# frozen_string_literal: true

require_relative "pretty_tree/version"

require_relative "pretty_tree/adapter"
require_relative "pretty_tree/adapter/array_tree"
require_relative "pretty_tree/formatter"
require_relative "pretty_tree/formatter/default"

module PrettyTree
  class Error < StandardError; end

  def self.render(tree, adapter: Adapter::ArrayTree.new, formatter: Formatter::Default.new)
    return "" if tree.nil?

    label = adapter.value(tree)
    _children = adapter.children(tree)

    formatter.label(label, max_width: 12)
  end

  def self.print(tree, adapter: Adapter::ArrayTree.new, formatter: Formatter::Default.new)
    puts render(tree, adapter:, formatter:)
  end
end

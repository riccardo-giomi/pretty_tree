# frozen_string_literal: true

require_relative "pretty_tree/version"

require_relative "pretty_tree/adapter"
require_relative "pretty_tree/adapter/array_tree"
require_relative "pretty_tree/formatter"
require_relative "pretty_tree/formatter/default"

require_relative "pretty_tree/renderer"

module PrettyTree
  class Error < StandardError; end

  def self.render(tree, adapter: Adapter::ArrayTree.new, formatter: Formatter::Default.new)
    Renderer.new(adapter:, formatter:).box_for(tree).join("\n")
  end

  def self.print(tree, adapter: Adapter::ArrayTree.new, formatter: Formatter::Default.new)
    puts render(tree, adapter:, formatter:)
  end
end

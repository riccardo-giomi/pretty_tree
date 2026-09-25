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
    Renderer.new(adapter:, formatter:).call(tree)
  end

  def self.print(tree, adapter: Adapter::ArrayTree.new, formatter: Formatter::Default.new)
    puts render(tree, adapter:, formatter:)
  end

  # Prints some example trees as a preview of the output.
  def self.preview(adapter: Adapter::ArrayTree.new, formatter: Formatter::Default.new)
    require_relative "pretty_tree/preview"
    Preview.new(adapter:, formatter:).run
  end
end

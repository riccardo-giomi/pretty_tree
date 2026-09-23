# frozen_string_literal: true

require_relative "pretty_tree/version"

require_relative "pretty_tree/formatter"
require_relative "pretty_tree/formatter/default"

module PrettyTree
  class Error < StandardError; end

  def self.render(tree, formatter: Formatter::Default.new)
    return "" if tree.nil?
    formatter.label(tree.first, max_width: 12)
  end

  def self.print(tree)
    puts render(tree)
  end
end

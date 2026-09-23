# frozen_string_literal: true

require_relative "pretty_tree/version"

module PrettyTree
  class Error < StandardError; end

  def self.render(tree)
    return "" if tree.nil?
    tree.first.inspect
  end

  def self.print(tree)
    puts render(tree)
  end
end

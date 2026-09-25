# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "standard/rake"

desc "Print example trees"
task :preview do
  require_relative "lib/pretty_tree"
  PrettyTree.preview
end

task default: %i[test standard]

# frozen_string_literal: true

require "test_helper"

class TestPrettyTree < Minitest::Test
  class ReverseFormatterStub
    def label(value, max_width: nil) = value.to_s.reverse
  end

  def test_that_it_has_a_version_number
    refute_nil ::PrettyTree::VERSION
  end

  def test_renders_nil_as_empty_string
    assert_equal "", PrettyTree.render(nil)
  end

  def test_renders_single_node_as_string
    assert_equal "\"a\"", PrettyTree.render(["a", nil, nil])
  end

  def test_long_node_values_are_truncated
    assert_equal "\"morethan...", PrettyTree.render(["morethan10chars"])
  end

  def test_print_writes_render_output_to_stdout_with_trailing_newline
    out, _err = capture_io { PrettyTree.print(["x"]) }
    assert_equal "\"x\"\n", out
  end

  def test_print_forwards_formatter_arguments
    tree = ["cat", nil, nil]

    out, _err = capture_io do
      PrettyTree.print(tree, formatter: ReverseFormatterStub.new)
    end

    assert_equal "tac\n", out
  end
end

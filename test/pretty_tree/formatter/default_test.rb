# frozen_string_literal: true

require "test_helper"

class DefaultTest < Minitest::Test
  def formatter
    PrettyTree::Formatter::Default.new
  end

  def test_is_a_pretty_tree_formatter
    assert_kind_of PrettyTree::Formatter, formatter
  end

  def test_label_returns_inspect_string_for_a_string
    assert_equal "\"a\"", formatter.label("a")
  end

  def test_label_returns_inspect_string_for_an_integer
    assert_equal "1", formatter.label(1)
  end

  def test_label_returns_inspect_string_for_nil
    assert_equal "nil", formatter.label(nil)
  end

  def test_label_truncates_to_max_width_including_including_ellipsis
    assert_equal "\"this is ...", formatter.label("this is a long label", max_width: 12)
  end

  def test_label_truncates_without_ellipsis_if_max_width_is_small_enough
    assert_equal "\"th", formatter.label("this is a long label", max_width: 3)
  end
end

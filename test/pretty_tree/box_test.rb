# frozen_string_literal: true

require "test_helper"

class BoxTest < Minitest::Test
  def test_leaf_wraps_label_in_a_single_line
    box = PrettyTree::Box.leaf("abc")

    assert_equal ["abc"], box.lines
  end

  def test_leaf_width_is_label_size
    assert_equal 5, PrettyTree::Box.leaf("hello").width
  end

  def test_leaf_anchor_is_middle_column_for_odd_width
    assert_equal 2, PrettyTree::Box.leaf("hello").anchor
  end

  def test_leaf_anchor_is_right_of_center_for_even_width
    assert_equal 2, PrettyTree::Box.leaf("abcd").anchor
  end

  def test_leaf_anchor_can_be_given_explicitly
    box = PrettyTree::Box.leaf("abcd", anchor: 1)

    assert_equal 1, box.anchor
    assert_equal 4, box.width
    assert_equal ["abcd"], box.lines
  end

  def test_leaf_is_not_empty_by_default
    refute PrettyTree::Box.leaf("a").empty?
  end

  def test_leaf_can_be_marked_empty
    assert PrettyTree::Box.leaf("   ", empty: true).empty?
  end

  def test_leaf_with_empty_string_has_zero_width_and_anchor
    box = PrettyTree::Box.leaf("")

    assert_equal 0, box.width
    assert_equal 0, box.anchor
  end

  def test_empty_builds_an_empty_leaf
    box = PrettyTree::Box.empty("   ")

    assert box.empty?
    assert_equal ["   "], box.lines
    assert_equal 3, box.width
    assert_equal 1, box.anchor
  end

  def test_empty_anchor_can_be_given_explicitly
    box = PrettyTree::Box.empty("    ", anchor: 2)

    assert box.empty?
    assert_equal 2, box.anchor
  end

  def test_empty_with_empty_string_takes_no_room
    box = PrettyTree::Box.empty("")

    assert box.empty?
    assert_equal [""], box.lines
    assert_equal 0, box.width
    assert_equal 0, box.anchor
  end

  def test_height_is_number_of_lines
    box = PrettyTree::Box.new(["a", "b", "c"], 1, 0)

    assert_equal 3, box.height
  end

  def test_height_of_leaf_is_one
    assert_equal 1, PrettyTree::Box.leaf("x").height
  end

  def test_empty_predicate_is_false_when_flag_is_nil
    refute PrettyTree::Box.new(["x"], 1, 0).empty?
  end

  def test_empty_predicate_is_false_when_flag_is_false
    refute PrettyTree::Box.new(["x"], 1, 0, false).empty?
  end

  def test_empty_predicate_is_true_when_flag_is_true
    assert PrettyTree::Box.new([" "], 1, 0, true).empty?
  end

  def test_empty_predicate_always_returns_a_boolean
    assert_same false, PrettyTree::Box.new(["x"], 1, 0).empty?
    assert_same true, PrettyTree::Box.new([" "], 1, 0, true).empty?
  end
end

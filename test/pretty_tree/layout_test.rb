# frozen_string_literal: true

require "test_helper"

class LayoutTest < Minitest::Test
  def test_min_leaf_size_leaves_room_for_connectors
    assert_equal 3, PrettyTree::Layout::MIN_LEAF_SIZE
  end

  def test_pad_label_centers_short_label
    assert_equal " a ", PrettyTree::Layout.pad_label("a")
  end

  def test_pad_label_puts_the_extra_space_on_the_right
    assert_equal "ab ", PrettyTree::Layout.pad_label("ab")
  end

  def test_pad_label_leaves_label_of_min_size_untouched
    assert_equal "abc", PrettyTree::Layout.pad_label("abc")
  end

  def test_pad_label_leaves_longer_label_untouched
    assert_equal "hello", PrettyTree::Layout.pad_label("hello")
  end

  def test_pad_label_of_empty_string_is_all_spaces
    assert_equal "   ", PrettyTree::Layout.pad_label("")
  end

  def test_pad_label_of_nil_is_all_spaces
    assert_equal "   ", PrettyTree::Layout.pad_label(nil)
  end

  def test_pad_label_converts_non_strings
    assert_equal " 7 ", PrettyTree::Layout.pad_label(7)
    assert_equal " a ", PrettyTree::Layout.pad_label(:a)
  end

  def test_empty_node_is_an_empty_box
    assert PrettyTree::Layout.empty_node.empty?
  end

  def test_empty_node_is_blank_and_min_leaf_wide
    box = PrettyTree::Layout.empty_node

    assert_equal ["   "], box.lines
    assert_equal 3, box.width
    assert_equal 1, box.anchor
  end

  def test_leaf_node_is_not_empty
    refute PrettyTree::Layout.leaf_node("a").empty?
  end

  def test_leaf_node_pads_short_label
    box = PrettyTree::Layout.leaf_node("a")

    assert_equal [" a "], box.lines
    assert_equal 3, box.width
    assert_equal 1, box.anchor
  end

  def test_leaf_node_keeps_long_label_and_anchors_on_its_middle
    box = PrettyTree::Layout.leaf_node("hello")

    assert_equal ["hello"], box.lines
    assert_equal 5, box.width
    assert_equal 2, box.anchor
  end

  def test_leaf_node_of_even_label_anchors_right_of_center
    box = PrettyTree::Layout.leaf_node("abcd")

    assert_equal 4, box.width
    assert_equal 2, box.anchor
  end
end

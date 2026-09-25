# frozen_string_literal: true

require "test_helper"

class LayoutTest < Minitest::Test
  def test_min_leaf_size_leaves_room_for_connectors
    assert_equal 3, PrettyTree::Layout::MIN_LEAF_SIZE
  end

  def test_min_binary_leaf_size_leaves_room_for_two_connectors
    assert_equal 5, PrettyTree::Layout::MIN_BINARY_LEAF_SIZE
  end

  def test_pad_label_centers_short_label
    assert_equal " a ", PrettyTree::Layout.pad_label("a", parent_arity: 1)
  end

  def test_pad_label_puts_the_extra_space_on_the_right
    assert_equal "ab ", PrettyTree::Layout.pad_label("ab", parent_arity: 1)
  end

  def test_pad_label_leaves_label_of_min_size_untouched
    assert_equal "abc", PrettyTree::Layout.pad_label("abc", parent_arity: 1)
  end

  def test_pad_label_leaves_longer_label_untouched
    assert_equal "hello", PrettyTree::Layout.pad_label("hello", parent_arity: 1)
  end

  def test_pad_label_of_empty_string_is_all_spaces
    assert_equal "   ", PrettyTree::Layout.pad_label("", parent_arity: 1)
  end

  def test_pad_label_of_nil_is_all_spaces
    assert_equal "   ", PrettyTree::Layout.pad_label(nil, parent_arity: 1)
  end

  def test_pad_label_converts_non_strings
    assert_equal " 7 ", PrettyTree::Layout.pad_label(7, parent_arity: 1)
    assert_equal " a ", PrettyTree::Layout.pad_label(:a, parent_arity: 1)
  end

  def test_pad_label_uses_binary_leaf_size_for_parent_arity_two
    assert_equal "  a  ", PrettyTree::Layout.pad_label("a", parent_arity: 2)
  end

  def test_pad_label_of_nil_is_binary_leaf_wide_for_parent_arity_two
    assert_equal "     ", PrettyTree::Layout.pad_label(nil, parent_arity: 2)
  end

  def test_pad_label_leaves_label_longer_than_binary_leaf_size_untouched
    assert_equal "abcdef", PrettyTree::Layout.pad_label("abcdef", parent_arity: 2)
  end

  def test_pad_label_uses_min_leaf_size_for_parent_arity_three
    assert_equal " a ", PrettyTree::Layout.pad_label("a", parent_arity: 3)
  end

  def test_empty_box_is_an_empty_box
    assert PrettyTree::Layout.empty_box(parent_arity: 1).empty?
  end

  def test_empty_box_is_blank_and_min_leaf_wide
    box = PrettyTree::Layout.empty_box(parent_arity: 1)

    assert_equal ["   "], box.lines
    assert_equal 3, box.width
    assert_equal 1, box.anchor
  end

  def test_empty_box_is_binary_leaf_wide_for_parent_arity_two
    box = PrettyTree::Layout.empty_box(parent_arity: 2)

    assert_equal ["     "], box.lines
    assert_equal 5, box.width
    assert_equal 2, box.anchor
  end

  def test_empty_box_is_min_leaf_wide_for_parent_arity_three
    box = PrettyTree::Layout.empty_box(parent_arity: 3)

    assert_equal ["   "], box.lines
    assert_equal 3, box.width
  end

  def test_leaf_box_is_not_empty
    refute PrettyTree::Layout.leaf_box("a", parent_arity: 1).empty?
  end

  def test_leaf_box_pads_short_label
    box = PrettyTree::Layout.leaf_box("a", parent_arity: 1)

    assert_equal [" a "], box.lines
    assert_equal 3, box.width
    assert_equal 1, box.anchor
  end

  def test_leaf_box_pads_short_label_to_binary_leaf_size_for_parent_arity_two
    box = PrettyTree::Layout.leaf_box("a", parent_arity: 2)

    assert_equal ["  a  "], box.lines
    assert_equal 5, box.width
    assert_equal 2, box.anchor
  end

  def test_leaf_box_keeps_long_label_and_anchors_on_its_middle
    box = PrettyTree::Layout.leaf_box("hello", parent_arity: 1)

    assert_equal ["hello"], box.lines
    assert_equal 5, box.width
    assert_equal 2, box.anchor
  end

  def test_leaf_box_of_even_label_anchors_right_of_center
    box = PrettyTree::Layout.leaf_box("abcd", parent_arity: 1)

    assert_equal 4, box.width
    assert_equal 2, box.anchor
  end

  def test_node_box_with_only_empty_children_is_a_leaf_box
    children = [PrettyTree::Layout.empty_box(parent_arity: 2), PrettyTree::Layout.empty_box(parent_arity: 2)]
    box = PrettyTree::Layout.node_box("a", children, parent_arity: 1)

    assert_equal [" a "], box.lines
    refute box.empty?
  end

  def test_node_box_with_only_empty_children_pads_for_its_own_parent_arity
    children = [PrettyTree::Layout.empty_box(parent_arity: 2), PrettyTree::Layout.empty_box(parent_arity: 2)]
    box = PrettyTree::Layout.node_box("a", children, parent_arity: 2)

    assert_equal ["  a  "], box.lines
    assert_equal 5, box.width
  end

  def test_node_box_with_no_children_is_a_leaf_box
    box = PrettyTree::Layout.node_box("a", [], parent_arity: 1)

    assert_equal [" a "], box.lines
    refute box.empty?
  end

  def test_layout_for_picks_a_layout_by_number_of_boxes
    assert_instance_of PrettyTree::Layout::Unary, PrettyTree::Layout.layout_for(boxes(1))
    assert_instance_of PrettyTree::Layout::Binary, PrettyTree::Layout.layout_for(boxes(2))
    assert_instance_of PrettyTree::Layout::Ternary, PrettyTree::Layout.layout_for(boxes(3))
  end

  def test_layout_for_falls_back_to_generic_for_more_than_three_boxes
    assert_instance_of PrettyTree::Layout::Generic, PrettyTree::Layout.layout_for(boxes(4))
    assert_instance_of PrettyTree::Layout::Generic, PrettyTree::Layout.layout_for(boxes(7))
  end

  def test_layout_for_hands_the_boxes_to_the_layout
    _, width, offsets = PrettyTree::Layout.layout_for(boxes(2)).merge

    assert_equal 11, width
    assert_equal [2, 8], offsets
  end

  def test_every_layout_is_a_base_layout
    [PrettyTree::Layout::Unary, PrettyTree::Layout::Binary, PrettyTree::Layout::Ternary, PrettyTree::Layout::Generic].each do |layout|
      assert_operator layout, :<, PrettyTree::Layout::Base
    end
  end

  def test_node_box_of_a_binary_node_draws_label_connectors_and_children
    children = [PrettyTree::Layout.leaf_box("2", parent_arity: 2), PrettyTree::Layout.leaf_box("3", parent_arity: 2)]
    box = PrettyTree::Layout.node_box("1", children, parent_arity: 1)

    assert_equal ["     1     ", "    / \\    ", "   /   \\   ", "  2     3  "], box.lines
  end

  def test_node_box_of_a_binary_node_has_the_merged_width_and_label_anchor
    children = [PrettyTree::Layout.leaf_box("2", parent_arity: 2), PrettyTree::Layout.leaf_box("3", parent_arity: 2)]
    box = PrettyTree::Layout.node_box("1", children, parent_arity: 1)

    assert_equal 11, box.width
    assert_equal 5, box.anchor
    refute box.empty?
  end

  def test_node_box_of_a_binary_node_is_three_lines_taller_than_its_children
    children = [PrettyTree::Layout.leaf_box("2", parent_arity: 2), PrettyTree::Layout.leaf_box("3", parent_arity: 2)]

    assert_equal 4, PrettyTree::Layout.node_box("1", children, parent_arity: 1).height
  end

  def test_node_box_of_a_binary_node_with_only_a_left_child
    children = [PrettyTree::Layout.leaf_box("2", parent_arity: 2), PrettyTree::Layout.empty_box(parent_arity: 2)]
    box = PrettyTree::Layout.node_box("1", children, parent_arity: 1)

    assert_equal ["     1     ", "    /      ", "   /       ", "  2        "], box.lines
  end

  def test_node_box_of_a_binary_node_with_only_a_right_child
    children = [PrettyTree::Layout.empty_box(parent_arity: 2), PrettyTree::Layout.leaf_box("3", parent_arity: 2)]
    box = PrettyTree::Layout.node_box("1", children, parent_arity: 1)

    assert_equal ["     1     ", "      \\    ", "       \\   ", "        3  "], box.lines
  end

  def test_node_box_of_a_binary_node_with_children_of_different_heights
    tall = PrettyTree::Box.new(["  2  ", " / \\ ", "  4  "], 5, 2, false)
    box = PrettyTree::Layout.node_box("1", [tall, PrettyTree::Layout.leaf_box("3", parent_arity: 2)], parent_arity: 1)

    assert_equal ["     1     ", "    / \\    ", "   /   \\   ", "  2     3  ", " / \\       ", "  4        "], box.lines
    assert_equal [11], box.lines.map(&:size).uniq
  end

  def test_node_box_of_a_binary_node_with_wide_children_uses_underscores
    children = [PrettyTree::Layout.leaf_box("w" * 12, parent_arity: 2), PrettyTree::Layout.leaf_box("v" * 12, parent_arity: 2)]
    box = PrettyTree::Layout.node_box("1", children, parent_arity: 1)

    assert_equal 25, box.width
    assert_equal 12, box.anchor
    assert_equal ["            1            ", "        ____|_____       ", "       /          \\      ", "wwwwwwwwwwww vvvvvvvvvvvv"], box.lines
  end

  def test_node_box_of_a_unary_node_draws_a_straight_bar_to_its_child
    box = PrettyTree::Layout.node_box("1", [PrettyTree::Layout.leaf_box("2", parent_arity: 1)], parent_arity: 1)

    assert_equal [" 1 ", " | ", " | ", " 2 "], box.lines
  end

  def test_node_box_of_a_unary_node_has_its_childs_width_and_anchor
    box = PrettyTree::Layout.node_box("1", [PrettyTree::Layout.leaf_box("2", parent_arity: 1)], parent_arity: 1)

    assert_equal 3, box.width
    assert_equal 1, box.anchor
    refute box.empty?
  end

  def test_node_box_of_a_unary_node_with_a_wide_child
    child = PrettyTree::Layout.leaf_box("w" * 12, parent_arity: 1)
    box = PrettyTree::Layout.node_box("1", [child], parent_arity: 1)

    assert_equal ["      1     ", "      |     ", "      |     ", "wwwwwwwwwwww"], box.lines
    assert_equal 6, box.anchor
  end

  def test_node_box_of_a_unary_node_stacks_on_a_taller_child
    tall = PrettyTree::Box.new(["  2  ", " / \\ ", "  4  "], 5, 2, false)
    box = PrettyTree::Layout.node_box("1", [tall], parent_arity: 1)

    assert_equal ["  1  ", "  |  ", "  |  ", "  2  ", " / \\ ", "  4  "], box.lines
  end

  def test_node_box_of_a_unary_node_does_not_depend_on_its_own_parent_arity
    child = PrettyTree::Layout.leaf_box("2", parent_arity: 1)

    assert_equal PrettyTree::Layout.node_box("1", [child], parent_arity: 1).lines,
      PrettyTree::Layout.node_box("1", [child], parent_arity: 3).lines
  end

  def test_node_box_of_a_ternary_node_draws_label_connectors_and_children
    children = %w[2 3 4].map { |label| PrettyTree::Layout.leaf_box(label, parent_arity: 3) }
    box = PrettyTree::Layout.node_box("1", children, parent_arity: 1)

    assert_equal ["     1     ", "   / | \\   ", "  /  |  \\  ", " 2   3   4 "], box.lines
  end

  def test_node_box_of_a_ternary_node_has_the_merged_width_and_middle_anchor
    children = %w[2 3 4].map { |label| PrettyTree::Layout.leaf_box(label, parent_arity: 3) }
    box = PrettyTree::Layout.node_box("1", children, parent_arity: 1)

    assert_equal 11, box.width
    assert_equal 5, box.anchor
    assert_equal 4, box.height
  end

  def test_node_box_of_a_ternary_node_with_only_a_middle_child
    children = [PrettyTree::Layout.empty_box(parent_arity: 3), PrettyTree::Layout.leaf_box("3", parent_arity: 3), PrettyTree::Layout.empty_box(parent_arity: 3)]
    box = PrettyTree::Layout.node_box("1", children, parent_arity: 1)

    assert_equal ["     1     ", "     |     ", "     |     ", "     3     "], box.lines
  end

  def test_node_box_of_a_ternary_node_without_a_middle_child
    children = [PrettyTree::Layout.leaf_box("2", parent_arity: 3), PrettyTree::Layout.empty_box(parent_arity: 3), PrettyTree::Layout.leaf_box("4", parent_arity: 3)]
    box = PrettyTree::Layout.node_box("1", children, parent_arity: 1)

    assert_equal ["     1     ", "   /   \\   ", "  /     \\  ", " 2       4 "], box.lines
  end

  def test_node_box_widens_to_fit_a_label_wider_than_its_children
    children = %w[1 2].map { |label| PrettyTree::Layout.leaf_box(label, parent_arity: 2) }
    box = PrettyTree::Layout.node_box("123456789012", children, parent_arity: 1)

    assert_equal ["123456789012", "     / \\    ", "    /   \\   ", "   1     2  "], box.lines
    assert_equal 12, box.width
    assert_equal 6, box.anchor
  end

  def test_node_box_of_a_unary_node_widens_to_fit_a_wide_label
    child = PrettyTree::Layout.leaf_box("1", parent_arity: 1)
    box = PrettyTree::Layout.node_box("123456789012", [child], parent_arity: 1)

    assert_equal ["123456789012", "      |     ", "      |     ", "      1     "], box.lines
    assert_equal 6, box.anchor
  end

  def test_node_box_of_a_ternary_node_widens_to_fit_a_wide_label
    children = %w[1 2 3].map { |label| PrettyTree::Layout.leaf_box(label, parent_arity: 3) }
    box = PrettyTree::Layout.node_box("123456789012", children, parent_arity: 1)

    assert_equal ["123456789012", "    / | \\   ", "   /  |  \\  ", "  1   2   3 "], box.lines
  end

  def test_node_box_with_a_wide_label_has_lines_of_equal_width
    children = %w[1 2].map { |label| PrettyTree::Layout.leaf_box(label, parent_arity: 2) }
    box = PrettyTree::Layout.node_box("123456789012", children, parent_arity: 1)

    assert_equal [box.width], box.lines.map(&:size).uniq
  end

  def test_node_box_does_not_widen_when_the_label_fits
    children = %w[1 2].map { |label| PrettyTree::Layout.leaf_box(label, parent_arity: 2) }

    assert_equal 11, PrettyTree::Layout.node_box("123", children, parent_arity: 1).width
  end

  def test_node_box_connectors_of_a_ternary_node_do_not_depend_on_label_length_up_to_the_min_leaf_size
    connectors = %w[1 22 333].map do |label|
      children = %w[3 4 5].map { |child| PrettyTree::Layout.leaf_box(child, parent_arity: 3) }
      PrettyTree::Layout.node_box(label, children, parent_arity: 3).lines[1..2]
    end

    assert_equal 1, connectors.uniq.size
    assert_equal ["   / | \\   ", "  /  |  \\  "], connectors.first
  end

  def test_node_box_connectors_of_a_binary_node_do_not_depend_on_label_length_up_to_the_min_binary_leaf_size
    connectors = %w[1 22 333 4444 55555].map do |label|
      children = %w[3 4].map { |child| PrettyTree::Layout.leaf_box(child, parent_arity: 2) }
      PrettyTree::Layout.node_box(label, children, parent_arity: 2).lines[1..2]
    end

    assert_equal 1, connectors.uniq.size
  end

  def generic_leaf(label)
    PrettyTree::Layout.leaf_box(label, parent_arity: 4)
  end

  def generic_empty
    PrettyTree::Layout.empty_box(parent_arity: 4)
  end

  def test_node_box_of_a_generic_node_draws_label_connectors_and_children
    children = %w[2 3 4 5].map { |label| generic_leaf(label) }
    box = PrettyTree::Layout.node_box("1", children, parent_arity: 1)

    assert_equal ["       1       ", "  _____|_____  ", " |   |   |   | ", " 2   3   4   5 "], box.lines
  end

  def test_node_box_of_a_generic_node_has_the_merged_width_and_label_anchor
    children = %w[2 3 4 5].map { |label| generic_leaf(label) }
    box = PrettyTree::Layout.node_box("1", children, parent_arity: 1)

    assert_equal 15, box.width
    assert_equal 7, box.anchor
    assert_equal 4, box.height
    refute box.empty?
  end

  def test_node_box_of_a_generic_node_reserves_no_space_for_empty_children
    children = [generic_leaf("2"), generic_empty, generic_leaf("4"), generic_empty, generic_leaf("6")]
    box = PrettyTree::Layout.node_box("1", children, parent_arity: 1)

    assert_equal ["     1     ", "  ___|___  ", " |   |   | ", " 2   4   6 "], box.lines
    assert_equal 11, box.width
  end

  def test_node_box_of_a_generic_node_with_a_single_real_child_is_a_straight_bar
    children = [generic_empty, generic_leaf("3"), generic_empty, generic_empty]
    box = PrettyTree::Layout.node_box("1", children, parent_arity: 1)

    assert_equal [" 1 ", " | ", " | ", " 3 "], box.lines
    assert_equal 1, box.anchor
  end

  def test_node_box_of_a_generic_node_widens_to_fit_a_wide_label
    children = %w[2 3 4 5].map { |label| generic_leaf(label) }
    box = PrettyTree::Layout.node_box("a" * 20, children, parent_arity: 1)

    assert_equal ["a" * 20, "     _____|_____    ", "    |   |   |   |   ", "    2   3   4   5   "], box.lines
    assert_equal 20, box.width
    assert_equal 10, box.anchor
  end

  def test_node_box_of_a_generic_node_has_lines_of_equal_width
    (4..8).each do |count|
      children = Array.new(count) { |i| generic_leaf((i + 2).to_s) }
      box = PrettyTree::Layout.node_box("1", children, parent_arity: 1)

      assert_equal [box.width], box.lines.map(&:size).uniq, "for #{count} children"
    end
  end

  def test_node_box_of_a_generic_node_with_children_of_different_heights
    tall = PrettyTree::Box.new(["  2  ", " / \\ ", "  4  "], 5, 2, false)
    box = PrettyTree::Layout.node_box("1", [tall, generic_leaf("3"), generic_leaf("5"), generic_leaf("6")], parent_arity: 1)

    assert_equal [box.width], box.lines.map(&:size).uniq
    assert_equal 6, box.height
  end

  def boxes(count)
    Array.new(count) { PrettyTree::Layout.empty_box(parent_arity: count) }
  end
end

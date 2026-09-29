# frozen_string_literal: true

require "test_helper"

class LayoutTest < Minitest::Test
  def leaf_box(label, parent_arity: 1, position: 0)
    PrettyTree::Layout.layout_class_for(parent_arity).leaf_box(label, position:)
  end

  def empty_box(parent_arity: 1)
    PrettyTree::Layout.empty_box(parent_arity:)
  end

  def node_box(label, children, parent_arity: 1, position: 0)
    PrettyTree::Layout.node_box(label, children, parent_arity:, position:)
  end

  def test_empty_box_is_an_empty_box
    assert empty_box.empty?
  end

  def test_empty_box_is_blank_and_min_leaf_wide
    box = empty_box(parent_arity: 1)

    assert_equal ["   "], box.lines
    assert_equal 3, box.width
    assert_equal 1, box.anchor
  end

  def test_empty_box_takes_no_room_for_parent_arity_two
    box = empty_box(parent_arity: 2)

    assert_equal [""], box.lines
    assert_equal 0, box.width
    assert box.empty?
  end

  def test_empty_box_is_min_leaf_wide_for_parent_arity_three
    box = empty_box(parent_arity: 3)

    assert_equal ["   "], box.lines
    assert_equal 3, box.width
  end

  def test_empty_box_is_asked_to_the_layout_of_the_parent_arity
    [1, 2, 3, 4, 7].each do |arity|
      expected = PrettyTree::Layout.layout_class_for(arity).empty_box

      assert_equal expected, empty_box(parent_arity: arity), "for parent arity #{arity}"
    end
  end

  def test_node_box_with_only_empty_children_is_a_leaf_box
    children = [empty_box(parent_arity: 2), empty_box(parent_arity: 2)]
    box = node_box("a", children, parent_arity: 1)

    assert_equal [" a "], box.lines
    refute box.empty?
  end

  def test_node_box_with_only_empty_children_is_a_left_leaf_for_a_binary_parent
    children = [empty_box(parent_arity: 2), empty_box(parent_arity: 2)]
    box = node_box("a", children, parent_arity: 2, position: 0)

    assert_equal [" a  "], box.lines
    assert_equal 4, box.width
    assert_equal 1, box.anchor
  end

  def test_node_box_with_only_empty_children_is_a_right_leaf_for_a_binary_parent
    children = [empty_box(parent_arity: 2), empty_box(parent_arity: 2)]
    box = node_box("a", children, parent_arity: 2, position: 1)

    assert_equal ["  a "], box.lines
    assert_equal 4, box.width
    assert_equal 2, box.anchor
  end

  def test_node_box_with_no_children_is_a_leaf_box
    box = node_box("a", [], parent_arity: 1)

    assert_equal [" a "], box.lines
    refute box.empty?
  end

  def test_layout_class_for_picks_a_layout_class_by_size
    assert_equal PrettyTree::Layout::Unary, PrettyTree::Layout.layout_class_for(1)
    assert_equal PrettyTree::Layout::Binary, PrettyTree::Layout.layout_class_for(2)
    assert_equal PrettyTree::Layout::Ternary, PrettyTree::Layout.layout_class_for(3)
    assert_equal PrettyTree::Layout::Generic, PrettyTree::Layout.layout_class_for(4)
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
    children = [leaf_box("2", parent_arity: 2, position: 0), leaf_box("3", parent_arity: 2, position: 1)]
    _, width, offsets = PrettyTree::Layout.layout_for(children).merge

    assert_equal 9, width
    assert_equal [1, 7], offsets
  end

  def test_every_layout_is_a_base_layout
    [PrettyTree::Layout::Unary, PrettyTree::Layout::Binary, PrettyTree::Layout::Ternary, PrettyTree::Layout::Generic].each do |layout|
      assert_operator layout, :<, PrettyTree::Layout::Base
    end
  end

  def test_node_box_of_a_binary_node_draws_label_connectors_and_children
    children = [leaf_box("2", parent_arity: 2), leaf_box("3", parent_arity: 2, position: 1)]
    box = node_box("1", children, parent_arity: 1)

    assert_equal ["    1    ", "   / \\   ", "  /   \\  ", " 2     3 "], box.lines
  end

  def test_node_box_of_a_binary_node_has_the_merged_width_and_label_anchor
    children = [leaf_box("2", parent_arity: 2), leaf_box("3", parent_arity: 2, position: 1)]
    box = node_box("1", children, parent_arity: 1)

    assert_equal 9, box.width
    assert_equal 4, box.anchor
    refute box.empty?
  end

  def test_node_box_of_a_binary_node_is_three_lines_taller_than_its_children
    children = [leaf_box("2", parent_arity: 2), leaf_box("3", parent_arity: 2, position: 1)]

    assert_equal 4, node_box("1", children, parent_arity: 1).height
  end

  def test_node_box_of_a_binary_node_with_only_a_left_child
    children = [leaf_box("2", parent_arity: 2), empty_box(parent_arity: 2)]
    box = node_box("1", children, parent_arity: 1)

    assert_equal ["    1 ", "   /  ", "  /   ", " 2    "], box.lines
  end

  def test_node_box_of_a_binary_node_with_only_a_right_child
    children = [empty_box(parent_arity: 2), leaf_box("3", parent_arity: 2, position: 1)]
    box = node_box("1", children, parent_arity: 1)

    assert_equal [" 1    ", "  \\   ", "   \\  ", "    3 "], box.lines
  end

  def test_node_box_of_a_binary_node_with_children_of_different_heights
    tall = PrettyTree::Box.new(["  2  ", " / \\ ", "  4  "], 5, 2, false)
    box = node_box("1", [tall, leaf_box("3", parent_arity: 2, position: 1)], parent_arity: 1)

    assert_equal ["     1    ", "    / \\   ", "   /   \\  ", "  2     3 ", " / \\      ", "  4       "], box.lines
    assert_equal [10], box.lines.map(&:size).uniq
  end

  def test_node_box_of_a_binary_node_with_wide_children_uses_underscores
    children = [leaf_box("w" * 12, parent_arity: 2), leaf_box("v" * 12, parent_arity: 2, position: 1)]
    box = node_box("1", children, parent_arity: 1)

    assert_equal 27, box.width
    assert_equal 13, box.anchor
    assert_equal ["             1             ", "        _____|______       ", "       /            \\      ", "wwwwwwwwwwww   vvvvvvvvvvvv"], box.lines
  end

  def test_node_box_of_a_unary_node_draws_a_straight_bar_to_its_child
    box = node_box("1", [leaf_box("2", parent_arity: 1)], parent_arity: 1)

    assert_equal [" 1 ", " | ", " | ", " 2 "], box.lines
  end

  def test_node_box_of_a_unary_node_has_its_childs_width_and_anchor
    box = node_box("1", [leaf_box("2", parent_arity: 1)], parent_arity: 1)

    assert_equal 3, box.width
    assert_equal 1, box.anchor
    refute box.empty?
  end

  def test_node_box_of_a_unary_node_with_a_wide_child
    child = leaf_box("w" * 12, parent_arity: 1)
    box = node_box("1", [child], parent_arity: 1)

    assert_equal ["      1     ", "      |     ", "      |     ", "wwwwwwwwwwww"], box.lines
    assert_equal 6, box.anchor
  end

  def test_node_box_of_a_unary_node_stacks_on_a_taller_child
    tall = PrettyTree::Box.new(["  2  ", " / \\ ", "  4  "], 5, 2, false)
    box = node_box("1", [tall], parent_arity: 1)

    assert_equal ["  1  ", "  |  ", "  |  ", "  2  ", " / \\ ", "  4  "], box.lines
  end

  def test_node_box_of_a_unary_node_does_not_depend_on_its_own_parent_arity
    child = leaf_box("2", parent_arity: 1)

    assert_equal node_box("1", [child], parent_arity: 1).lines,
      node_box("1", [child], parent_arity: 3).lines
  end

  def test_node_box_of_a_ternary_node_draws_label_connectors_and_children
    children = %w[2 3 4].map { |label| leaf_box(label, parent_arity: 3) }
    box = node_box("1", children, parent_arity: 1)

    assert_equal ["     1     ", "   / | \\   ", "  /  |  \\  ", " 2   3   4 "], box.lines
  end

  def test_node_box_of_a_ternary_node_has_the_merged_width_and_middle_anchor
    children = %w[2 3 4].map { |label| leaf_box(label, parent_arity: 3) }
    box = node_box("1", children, parent_arity: 1)

    assert_equal 11, box.width
    assert_equal 5, box.anchor
    assert_equal 4, box.height
  end

  def test_node_box_of_a_ternary_node_with_only_a_middle_child
    children = [empty_box(parent_arity: 3), leaf_box("3", parent_arity: 3), empty_box(parent_arity: 3)]
    box = node_box("1", children, parent_arity: 1)

    assert_equal ["     1     ", "     |     ", "     |     ", "     3     "], box.lines
  end

  def test_node_box_of_a_ternary_node_without_a_middle_child
    children = [leaf_box("2", parent_arity: 3), empty_box(parent_arity: 3), leaf_box("4", parent_arity: 3)]
    box = node_box("1", children, parent_arity: 1)

    assert_equal ["     1     ", "   /   \\   ", "  /     \\  ", " 2       4 "], box.lines
  end

  def test_node_box_widens_to_fit_a_label_wider_than_its_children
    children = %w[1 2].each_with_index.map { |label, i| leaf_box(label, parent_arity: 2, position: i) }
    box = node_box("123456789012", children, parent_arity: 1)

    assert_equal ["123456789012", "     / \\    ", "    /   \\   ", "   1     2  "], box.lines
    assert_equal 12, box.width
    assert_equal 6, box.anchor
  end

  def test_node_box_of_a_unary_node_widens_to_fit_a_wide_label
    child = leaf_box("1", parent_arity: 1)
    box = node_box("123456789012", [child], parent_arity: 1)

    assert_equal ["123456789012", "      |     ", "      |     ", "      1     "], box.lines
    assert_equal 6, box.anchor
  end

  def test_node_box_of_a_ternary_node_widens_to_fit_a_wide_label
    children = %w[1 2 3].map { |label| leaf_box(label, parent_arity: 3) }
    box = node_box("123456789012", children, parent_arity: 1)

    assert_equal ["123456789012", "    / | \\   ", "   /  |  \\  ", "  1   2   3 "], box.lines
  end

  def test_node_box_with_a_wide_label_has_lines_of_equal_width
    children = %w[1 2].each_with_index.map { |label, i| leaf_box(label, parent_arity: 2, position: i) }
    box = node_box("123456789012", children, parent_arity: 1)

    assert_equal [box.width], box.lines.map(&:size).uniq
  end

  def test_node_box_does_not_widen_when_the_label_fits
    children = %w[1 2].each_with_index.map { |label, i| leaf_box(label, parent_arity: 2, position: i) }

    assert_equal 9, node_box("123", children, parent_arity: 1).width
  end

  def test_node_box_connectors_of_a_ternary_node_do_not_depend_on_label_length_up_to_the_min_leaf_size
    connectors = %w[1 22 333].map do |label|
      children = %w[3 4 5].map { |child| leaf_box(child, parent_arity: 3) }
      node_box(label, children, parent_arity: 3).lines[1..2]
    end

    assert_equal 1, connectors.uniq.size
    assert_equal ["   / | \\   ", "  /  |  \\  "], connectors.first
  end

  def test_node_box_connectors_of_a_binary_node_do_not_depend_on_the_length_of_a_short_label
    connectors = %w[1 22 333 4444 55555].map do |label|
      children = %w[3 4].each_with_index.map { |child, i| leaf_box(child, parent_arity: 2, position: i) }
      node_box(label, children, parent_arity: 2).lines[1..2]
    end

    assert_equal 1, connectors.uniq.size
  end

  def generic_leaf(label)
    leaf_box(label, parent_arity: 4)
  end

  def generic_empty
    empty_box(parent_arity: 4)
  end

  def test_node_box_of_a_generic_node_draws_label_connectors_and_children
    children = %w[2 3 4 5].map { |label| generic_leaf(label) }
    box = node_box("1", children, parent_arity: 1)

    assert_equal ["       1       ", "  _____|_____  ", " |   |   |   | ", " 2   3   4   5 "], box.lines
  end

  def test_node_box_of_a_generic_node_has_the_merged_width_and_label_anchor
    children = %w[2 3 4 5].map { |label| generic_leaf(label) }
    box = node_box("1", children, parent_arity: 1)

    assert_equal 15, box.width
    assert_equal 7, box.anchor
    assert_equal 4, box.height
    refute box.empty?
  end

  def test_node_box_of_a_generic_node_reserves_no_space_for_empty_children
    children = [generic_leaf("2"), generic_empty, generic_leaf("4"), generic_empty, generic_leaf("6")]
    box = node_box("1", children, parent_arity: 1)

    assert_equal ["     1     ", "  ___|___  ", " |   |   | ", " 2   4   6 "], box.lines
    assert_equal 11, box.width
  end

  def test_node_box_of_a_generic_node_with_a_single_real_child_is_a_straight_bar
    children = [generic_empty, generic_leaf("3"), generic_empty, generic_empty]
    box = node_box("1", children, parent_arity: 1)

    assert_equal [" 1 ", " | ", " | ", " 3 "], box.lines
    assert_equal 1, box.anchor
  end

  def test_node_box_of_a_generic_node_widens_to_fit_a_wide_label
    children = %w[2 3 4 5].map { |label| generic_leaf(label) }
    box = node_box("a" * 20, children, parent_arity: 1)

    assert_equal ["a" * 20, "     _____|_____    ", "    |   |   |   |   ", "    2   3   4   5   "], box.lines
    assert_equal 20, box.width
    assert_equal 10, box.anchor
  end

  def test_node_box_of_a_generic_node_has_lines_of_equal_width
    (4..8).each do |count|
      children = Array.new(count) { |i| generic_leaf((i + 2).to_s) }
      box = node_box("1", children, parent_arity: 1)

      assert_equal [box.width], box.lines.map(&:size).uniq, "for #{count} children"
    end
  end

  def test_node_box_of_a_generic_node_with_children_of_different_heights
    tall = PrettyTree::Box.new(["  2  ", " / \\ ", "  4  "], 5, 2, false)
    box = node_box("1", [tall, generic_leaf("3"), generic_leaf("5"), generic_leaf("6")], parent_arity: 1)

    assert_equal [box.width], box.lines.map(&:size).uniq
    assert_equal 6, box.height
  end

  def boxes(count)
    Array.new(count) { empty_box(parent_arity: count) }
  end
end

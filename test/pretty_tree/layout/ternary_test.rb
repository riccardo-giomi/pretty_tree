# frozen_string_literal: true

require "test_helper"

class LayoutTernaryTest < Minitest::Test
  def leaf(label)
    PrettyTree::Layout.leaf_box(label, parent_arity: 3)
  end

  def empty
    PrettyTree::Layout.empty_box(parent_arity: 3)
  end

  def connectors_for(label, boxes)
    layout = PrettyTree::Layout::Ternary.new(boxes)
    _, width, offsets = layout.merge
    anchor = layout.label_anchor(offsets)
    layout.render_connector_lines(label, anchor, offsets, width)
  end

  def test_is_a_base_layout
    assert_operator PrettyTree::Layout::Ternary, :<, PrettyTree::Layout::Base
  end

  def test_label_anchor_is_the_anchor_of_the_middle_child
    assert_equal 5, PrettyTree::Layout::Ternary.new([]).label_anchor([1, 5, 9])
  end

  def test_label_anchor_ignores_the_side_children
    assert_equal 14, PrettyTree::Layout::Ternary.new([]).label_anchor([6, 14, 23])
  end

  def test_label_anchor_matches_the_merged_children_of_three_leaves
    layout = PrettyTree::Layout::Ternary.new([leaf("2"), leaf("3"), leaf("4")])
    _, _, offsets = layout.merge

    assert_equal 5, layout.label_anchor(offsets)
  end

  def test_connectors_of_three_leaves_meet_the_label
    assert_equal ["   __|__   ", "  /  |  \\  "], connectors_for("1", [leaf("2"), leaf("3"), leaf("4")])
  end

  def test_connectors_are_two_lines_as_wide_as_the_merged_children
    lines = connectors_for("1", [leaf("2"), leaf("3"), leaf("4")])

    assert_equal [11, 11], lines.map(&:size)
  end

  def test_connectors_with_only_a_middle_child_are_a_straight_bar
    assert_equal ["     |     ", "     |     "], connectors_for("1", [empty, leaf("3"), empty])
  end

  def test_connectors_with_only_a_left_child
    assert_equal ["   __|     ", "  /        "], connectors_for("1", [leaf("2"), empty, empty])
  end

  def test_connectors_with_only_a_right_child
    assert_equal ["     |__   ", "        \\  "], connectors_for("1", [empty, empty, leaf("4")])
  end

  def test_connectors_with_left_and_middle_children
    assert_equal ["   __|     ", "  /  |     "], connectors_for("1", [leaf("2"), leaf("3"), empty])
  end

  def test_connectors_with_middle_and_right_children
    assert_equal ["     |__   ", "     |  \\  "], connectors_for("1", [empty, leaf("3"), leaf("4")])
  end

  def test_connectors_with_left_and_right_children_and_no_middle
    assert_equal ["   __|__   ", "  /     \\  "], connectors_for("1", [leaf("2"), empty, leaf("4")])
  end

  def test_connectors_without_children_are_blank
    assert_equal ["           ", "           "], connectors_for("1", [empty, empty, empty])
  end

  def test_connectors_of_far_apart_children
    lines = connectors_for("1", [leaf("w" * 12), leaf("x"), leaf("v" * 12)])

    assert_equal ["        ______|_______       ", "       /      |       \\      "], lines
  end

  def test_connectors_of_far_apart_side_children_without_a_middle
    lines = connectors_for("1", [leaf("w" * 12), empty, leaf("v" * 12)])

    assert_equal ["        ______|_______       ", "       /              \\      "], lines
  end
end

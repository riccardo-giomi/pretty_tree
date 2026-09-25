# frozen_string_literal: true

require "test_helper"

class LayoutBinaryTest < Minitest::Test
  def leaf(label)
    PrettyTree::Layout.leaf_box(label, parent_arity: 2)
  end

  def empty
    PrettyTree::Layout.empty_box(parent_arity: 2)
  end

  def connectors_for(label, boxes)
    layout = PrettyTree::Layout::Binary.new(boxes)
    _, width, offsets = layout.merge
    anchor = layout.label_anchor(offsets)
    layout.render_connector_lines(label, anchor, boxes, offsets, width)
  end

  def test_is_a_base_layout
    assert_operator PrettyTree::Layout::Binary, :<, PrettyTree::Layout::Base
  end

  def test_label_anchor_is_midway_between_the_children_anchors
    assert_equal 5, PrettyTree::Layout::Binary.new([]).label_anchor([2, 8])
  end

  def test_label_anchor_for_adjacent_children
    assert_equal 2, PrettyTree::Layout::Binary.new([]).label_anchor([1, 4])
  end

  def test_label_anchor_matches_the_merged_children_of_two_leaves
    layout = PrettyTree::Layout::Binary.new([leaf("2"), leaf("3")])
    _, _, offsets = layout.merge

    assert_equal 5, layout.label_anchor(offsets)
  end

  def test_connectors_of_two_leaves_meet_the_label
    assert_equal ["    / \\    ", "   /   \\   "], connectors_for("1", [leaf("2"), leaf("3")])
  end

  def test_connectors_are_two_lines_as_wide_as_the_merged_children
    lines = connectors_for("1", [leaf("2"), leaf("3")])

    assert_equal [11, 11], lines.map(&:size)
  end

  def test_connectors_with_only_a_left_child
    assert_equal ["    /      ", "   /       "], connectors_for("1", [leaf("2"), empty])
  end

  def test_connectors_with_only_a_right_child
    assert_equal ["      \\    ", "       \\   "], connectors_for("1", [empty, leaf("3")])
  end

  def test_connectors_without_children_are_blank
    assert_equal ["           ", "           "], connectors_for("1", [empty, empty])
  end

  def test_connectors_of_far_apart_children_are_drawn_with_underscores
    lines = connectors_for("1", [leaf("w" * 12), leaf("v" * 12)])

    assert_equal ["        ____|_____       ", "       /          \\      "], lines
  end

  def test_connectors_with_only_a_far_left_child
    lines = connectors_for("1", [leaf("w" * 12), empty])

    assert_equal ["        /         ", "       /          "], lines
  end

  def test_connectors_with_only_a_far_right_child
    lines = connectors_for("1", [empty, leaf("v" * 12)])

    assert_equal ["          \\       ", "           \\      "], lines
  end

  def test_render_left_branch_draws_on_both_lines
    layout = PrettyTree::Layout::Binary.new([])
    lines = layout.render_left_branch([" " * 11, " " * 11], "1", 5, [2, 8])

    assert_equal ["    /      ", "   /       "], lines
  end

  def test_render_right_branch_draws_on_both_lines
    layout = PrettyTree::Layout::Binary.new([])
    lines = layout.render_right_branch([" " * 11, " " * 11], "1", 5, [2, 8])

    assert_equal ["      \\    ", "       \\   "], lines
  end

  def test_render_branches_combine_on_the_same_lines
    layout = PrettyTree::Layout::Binary.new([])
    lines = [" " * 11, " " * 11]
    lines = layout.render_left_branch(lines, "1", 5, [2, 8])
    lines = layout.render_right_branch(lines, "1", 5, [2, 8])

    assert_equal ["    / \\    ", "   /   \\   "], lines
  end
end

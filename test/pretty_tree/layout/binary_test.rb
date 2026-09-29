# frozen_string_literal: true

require "test_helper"

class LayoutBinaryTest < Minitest::Test
  def left_leaf(label)
    PrettyTree::Layout::Binary.leaf_box(label, position: 0)
  end

  def right_leaf(label)
    PrettyTree::Layout::Binary.leaf_box(label, position: 1)
  end

  def empty
    PrettyTree::Layout::Binary.empty_box
  end

  def real_box
    PrettyTree::Box.new(lines: ["x"], width: 1, anchor: 0, empty: false)
  end

  def two_real_boxes
    PrettyTree::Layout::Binary.new([real_box, real_box])
  end

  def connectors_for(label, boxes)
    layout = PrettyTree::Layout::Binary.new(boxes)
    _, width, offsets = layout.merge
    anchor = layout.label_anchor(offsets)
    layout.render_connector_lines(label, anchor, offsets, width)
  end

  def test_is_a_base_layout
    assert_operator PrettyTree::Layout::Binary, :<, PrettyTree::Layout::Base
  end

  def test_left_leaf_box_has_a_spare_column_on_its_right
    box = left_leaf("a")

    assert_equal [" a  "], box.lines
    assert_equal 4, box.width
    refute box.empty?
  end

  def test_left_leaf_box_is_anchored_on_its_label
    assert_equal 1, left_leaf("a").anchor
  end

  def test_right_leaf_box_has_a_spare_column_on_its_left
    box = right_leaf("a")

    assert_equal ["  a "], box.lines
    assert_equal 4, box.width
    refute box.empty?
  end

  def test_right_leaf_box_is_anchored_on_its_label
    assert_equal 2, right_leaf("a").anchor
  end

  def test_leaf_boxes_keep_a_long_label_and_anchor_on_its_middle
    label = "w" * 12

    assert_equal [label + " "], left_leaf(label).lines
    assert_equal 6, left_leaf(label).anchor
    assert_equal [" " + label], right_leaf(label).lines
    assert_equal 7, right_leaf(label).anchor
  end

  def test_leaf_boxes_convert_non_strings
    assert_equal [" 7  "], left_leaf(7).lines
    assert_equal ["  a "], right_leaf(:a).lines
  end

  def test_empty_box_is_an_empty_box
    assert empty.empty?
  end

  def test_empty_box_takes_no_room
    box = empty

    assert_equal [""], box.lines
    assert_equal 0, box.width
  end

  def test_label_anchor_is_midway_between_the_children_anchors
    assert_equal 5, two_real_boxes.label_anchor([2, 8])
  end

  def test_label_anchor_for_adjacent_children
    assert_equal 2, two_real_boxes.label_anchor([1, 4])
  end

  def test_label_anchor_when_the_first_child_anchor_is_not_at_the_start
    assert_equal 9, two_real_boxes.label_anchor([5, 14])
  end

  def test_label_anchor_rounds_down_when_the_midpoint_is_fractional
    assert_equal 6, two_real_boxes.label_anchor([2, 11])
  end

  def test_label_anchor_with_a_wide_first_child_and_a_leaf
    assert_equal 6, two_real_boxes.label_anchor([5, 8])
  end

  def test_label_anchor_is_never_left_of_the_first_child_anchor
    layout = two_real_boxes

    [[2, 8], [2, 11], [5, 8], [5, 14], [5, 17], [9, 12]].each do |first, last|
      assert_operator layout.label_anchor([first, last]), :>=, first
    end
  end

  def test_label_anchor_of_two_wide_subtrees
    assert_equal 11, two_real_boxes.label_anchor([5, 17])
  end

  def test_label_anchor_matches_the_merged_children_of_two_leaves
    layout = PrettyTree::Layout::Binary.new([left_leaf("2"), right_leaf("3")])
    _, _, offsets = layout.merge

    assert_equal 4, layout.label_anchor(offsets)
  end

  def test_label_anchor_with_only_a_left_child_is_a_connector_span_to_its_right
    layout = PrettyTree::Layout::Binary.new([real_box, empty])

    assert_equal 4, layout.label_anchor([1, 5])
  end

  def test_label_anchor_with_only_a_left_child_does_not_depend_on_the_empty_slot
    layout = PrettyTree::Layout::Binary.new([real_box, empty])

    assert_equal 8, layout.label_anchor([5, 14])
    assert_equal 8, layout.label_anchor([5, 99])
  end

  def test_label_anchor_with_only_a_right_child_is_a_connector_span_to_its_left
    layout = PrettyTree::Layout::Binary.new([empty, real_box])

    assert_equal 5, layout.label_anchor([0, 8])
  end

  def test_label_anchor_with_only_a_right_child_does_not_depend_on_the_empty_slot
    layout = PrettyTree::Layout::Binary.new([empty, real_box])

    assert_equal 11, layout.label_anchor([-40, 14])
    assert_equal 11, layout.label_anchor([0, 14])
  end

  def test_merge_of_two_leaves_leaves_room_for_both_connectors
    lines, width, offsets = PrettyTree::Layout::Binary.new([left_leaf("2"), right_leaf("3")]).merge

    assert_equal [" 2     3 "], lines
    assert_equal 9, width
    assert_equal [1, 7], offsets
  end

  def test_merge_keeps_the_children_anchors_at_least_two_connector_spans_apart
    lines, width, offsets = two_real_boxes.merge

    assert_equal ["x     x"], lines
    assert_equal 7, width
    assert_equal [0, 6], offsets
  end

  def test_merge_spreads_every_line_of_the_children
    tall = PrettyTree::Box.new(lines: %w[a b], width: 1, anchor: 0, empty: false)
    lines, width, offsets = PrettyTree::Layout::Binary.new([tall, tall]).merge

    assert_equal ["a     a", "b     b"], lines
    assert_equal 7, width
    assert_equal [0, 6], offsets
  end

  def test_merge_does_not_spread_children_that_are_far_enough_apart
    wide = PrettyTree::Box.new(lines: ["x" * 9], width: 9, anchor: 4, empty: false)
    lines, width, offsets = PrettyTree::Layout::Binary.new([wide, wide]).merge

    assert_equal ["xxxxxxxxx xxxxxxxxx"], lines
    assert_equal 19, width
    assert_equal [4, 14], offsets
  end

  def test_merge_does_not_spread_a_child_from_an_empty_slot
    wide = PrettyTree::Box.new(lines: ["x" * 9], width: 9, anchor: 4, empty: false)

    _, width, offsets = PrettyTree::Layout::Binary.new([real_box, empty]).merge
    assert_equal 2, width
    assert_equal [0, 2], offsets

    _, width, offsets = PrettyTree::Layout::Binary.new([empty, wide]).merge
    assert_equal 10, width
    assert_equal [0, 5], offsets
  end

  def test_connectors_of_two_leaves_meet_the_label
    assert_equal ["   / \\   ", "  /   \\  "], connectors_for("1", [left_leaf("2"), right_leaf("3")])
  end

  def test_connectors_are_two_lines_as_wide_as_the_merged_children
    lines = connectors_for("1", [left_leaf("2"), right_leaf("3")])

    assert_equal [9, 9], lines.map(&:size)
  end

  def test_connectors_with_only_a_left_child
    assert_equal ["   / ", "  /  "], connectors_for("1", [left_leaf("2"), empty])
  end

  def test_connectors_with_only_a_right_child
    assert_equal [" \\   ", "  \\  "], connectors_for("1", [empty, right_leaf("3")])
  end

  def test_connectors_without_children_are_blank
    lines = connectors_for("1", [empty, empty])

    assert lines.all? { |line| line.strip.empty? }
  end

  def test_connectors_of_far_apart_children_are_drawn_with_underscores
    lines = connectors_for("1", [left_leaf("w" * 12), right_leaf("v" * 12)])

    assert_equal ["        _____|______       ", "       /            \\      "], lines
  end

  def test_connectors_with_only_a_far_left_child
    lines = connectors_for("1", [left_leaf("w" * 12), empty])

    assert_equal ["        /     ", "       /      "], lines
  end

  def test_connectors_with_only_a_far_right_child
    lines = connectors_for("1", [empty, right_leaf("v" * 12)])

    assert_equal ["      \\       ", "       \\      "], lines
  end
end

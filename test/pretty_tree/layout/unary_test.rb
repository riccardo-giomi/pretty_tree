# frozen_string_literal: true

require "test_helper"

class LayoutUnaryTest < Minitest::Test
  def leaf(label)
    PrettyTree::Layout::Unary.leaf_box(label, position: 0)
  end

  def empty
    PrettyTree::Layout.empty_box(parent_arity: 1)
  end

  def connectors_for(label, boxes)
    layout = PrettyTree::Layout::Unary.new(boxes)
    _, width, offsets = layout.merge
    anchor = layout.label_anchor(offsets)
    layout.render_connector_lines(label, anchor, offsets, width)
  end

  def test_is_a_base_layout
    assert_operator PrettyTree::Layout::Unary, :<, PrettyTree::Layout::Base
  end

  def test_label_anchor_is_the_anchor_of_the_only_child
    assert_equal 1, PrettyTree::Layout::Unary.new([]).label_anchor([1])
  end

  def test_label_anchor_of_a_wide_child
    assert_equal 6, PrettyTree::Layout::Unary.new([]).label_anchor([6])
  end

  def test_label_anchor_matches_the_merged_child
    layout = PrettyTree::Layout::Unary.new([leaf("w" * 12)])
    _, _, offsets = layout.merge

    assert_equal 6, layout.label_anchor(offsets)
  end

  def test_connectors_are_a_straight_bar_down_to_the_child
    assert_equal [" | ", " | "], connectors_for("1", [leaf("2")])
  end

  def test_connectors_are_as_wide_as_the_child
    lines = connectors_for("1", [leaf("w" * 12)])

    assert_equal ["      |     ", "      |     "], lines
  end

  def test_connectors_of_an_empty_child_are_blank
    assert_equal ["   ", "   "], connectors_for("1", [empty])
  end

  def test_connectors_bar_is_under_the_child_anchor_of_a_tall_child
    tall = PrettyTree::Box.new(["  2  ", " / \\ ", "  4  "], 5, 2, false)

    assert_equal ["  |  ", "  |  "], connectors_for("1", [tall])
  end
end

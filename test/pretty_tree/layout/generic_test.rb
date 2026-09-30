# frozen_string_literal: true

require "test_helper"

class LayoutGenericTest < Minitest::Test
  def leaf(label)
    PrettyTree::Layout::Generic.leaf_box(label, position: 0)
  end

  def empty
    PrettyTree::Layout.empty_box(parent_arity: 4)
  end

  def leaves(count)
    Array.new(count) { |i| leaf((i + 2).to_s) }
  end

  def connectors_for(boxes, label = "1")
    layout = PrettyTree::Layout::Generic.new(boxes)
    _, width, offsets = layout.merge
    anchor = layout.label_anchor(offsets)
    layout.render_connector_lines(label, anchor, offsets, width)
  end

  def test_is_a_base_layout
    assert_operator PrettyTree::Layout::Generic, :<, PrettyTree::Layout::Base
  end

  def test_merge_places_all_boxes_side_by_side
    lines, width, offsets = PrettyTree::Layout::Generic.new(leaves(4)).merge

    assert_equal [" 2   3   4   5 "], lines
    assert_equal 15, width
    assert_equal [1, 5, 9, 13], offsets
  end

  def test_merge_ignores_empty_boxes
    lines, width, offsets = PrettyTree::Layout::Generic.new([leaf("2"), empty, leaf("4"), empty, leaf("6")]).merge

    assert_equal [" 2   4   6 "], lines
    assert_equal 11, width
    assert_equal [1, 5, 9], offsets
  end

  def test_merge_ignores_empty_boxes_at_the_start_and_end
    lines, _, offsets = PrettyTree::Layout::Generic.new([empty, leaf("2"), leaf("3"), empty]).merge

    assert_equal [" 2   3 "], lines
    assert_equal [1, 5], offsets
  end

  def test_merge_of_a_single_real_box_among_empty_ones
    lines, width, offsets = PrettyTree::Layout::Generic.new([empty, empty, leaf("3"), empty]).merge

    assert_equal [" 3 "], lines
    assert_equal 3, width
    assert_equal [1], offsets
  end

  def test_label_anchor_of_a_single_offset_is_that_offset
    assert_equal 3, PrettyTree::Layout::Generic.new([]).label_anchor([3])
  end

  def test_label_anchor_of_an_odd_number_of_offsets_is_the_middle_one
    layout = PrettyTree::Layout::Generic.new([])

    assert_equal 5, layout.label_anchor([1, 5, 9])
    assert_equal 9, layout.label_anchor([1, 5, 9, 13, 17])
    assert_equal 13, layout.label_anchor([1, 5, 9, 13, 17, 21, 25])
  end

  def test_label_anchor_of_an_even_number_of_offsets_is_between_the_two_middle_ones
    layout = PrettyTree::Layout::Generic.new([])

    assert_equal 3, layout.label_anchor([1, 5])
    assert_equal 7, layout.label_anchor([1, 5, 9, 13])
    assert_equal 11, layout.label_anchor([1, 5, 9, 13, 17, 21])
  end

  def test_label_anchor_of_unevenly_spaced_offsets
    layout = PrettyTree::Layout::Generic.new([])

    assert_equal 11, layout.label_anchor([1, 9, 13, 17])
    assert_equal 18, layout.label_anchor([3, 13, 23, 33])
    assert_equal 25, layout.label_anchor([6, 19, 32, 45])
    assert_equal 7, layout.label_anchor([2, 12])
  end

  def test_label_anchor_ignores_the_outer_offsets
    layout = PrettyTree::Layout::Generic.new([])

    assert_equal layout.label_anchor([1, 5, 9, 13]), layout.label_anchor([0, 5, 9, 40])
  end

  def test_connectors_of_four_children
    assert_equal ["  _____|_____  ", " |   |   |   | "], connectors_for(leaves(4))
  end

  def test_connectors_of_five_children_put_the_label_bar_over_the_middle_child
    assert_equal ["  _______|_______  ", " |   |   |   |   | "], connectors_for(leaves(5))
  end

  def test_connectors_of_six_children
    assert_equal ["  _________|_________  ", " |   |   |   |   |   | "], connectors_for(leaves(6))
  end

  def test_connectors_of_three_children_keep_the_generic_form
    assert_equal ["  ___|___  ", " |   |   | "], connectors_for(leaves(3))
  end

  def test_connectors_of_two_children
    assert_equal ["  _|_  ", " |   | "], connectors_for(leaves(2))
  end

  def test_connectors_of_a_single_child_are_a_straight_bar
    assert_equal [" | ", " | "], connectors_for(leaves(1))
  end

  def test_connectors_ignore_empty_children
    with_empties = connectors_for([leaf("2"), empty, leaf("3"), empty, empty, leaf("4")])

    assert_equal connectors_for(leaves(3)), with_empties
  end

  def test_connectors_of_a_single_real_child_among_empty_ones
    assert_equal [" | ", " | "], connectors_for([empty, empty, leaf("3"), empty])
  end

  def test_connector_lines_are_as_wide_as_the_merged_children
    (1..7).each do |count|
      expected_width = (count * 3) + (count - 1)

      assert_equal [expected_width], connectors_for(leaves(count)).map(&:size).uniq, "for #{count} children"
    end
  end

  def test_connector_underscores_stop_one_column_short_of_the_first_and_last_children
    top, bottom = connectors_for(leaves(4))

    assert_equal "  _____|_____  ", top
    assert_equal " |   |   |   | ", bottom
  end

  def test_connectors_take_positions_straight_from_the_offsets
    layout = PrettyTree::Layout::Generic.new([])

    assert_equal ["   _____|_____   ", "  |     |     |  "], layout.render_connector_lines("1", 8, [2, 8, 14], 17)
  end

  def test_connectors_put_the_label_bar_where_the_parent_anchor_says
    layout = PrettyTree::Layout::Generic.new([])

    assert_equal ["  _|_______  ", " |         | "], layout.render_connector_lines("1", 3, [1, 11], 13)
  end

  def test_connectors_of_far_apart_children_are_drawn_with_underscores_all_the_way
    children = ["w" * 12, "x", "v" * 12, "y"].map { |label| PrettyTree::Layout::Generic.leaf_box(label, position: 0) }
    top, bottom = connectors_for(children)

    assert_match(/\A {7}_+\|_+ {2}\z/, top)
    assert_equal 4, bottom.count("|")
    assert_equal top.size, bottom.size
  end

  def test_label_anchor_of_an_even_number_of_offsets_ignores_the_label_length
    layout = PrettyTree::Layout::Generic.new([])

    [1, 2, 3, 4, 5, 6, 12].each do |length|
      assert_equal 8, layout.label_anchor([1, 6, 11, 16], length), "for length #{length}"
      assert_equal 4, layout.label_anchor([1, 4, 5, 8], length), "for length #{length}"
    end
  end

  def test_label_anchor_of_an_odd_number_of_offsets_ignores_the_label_length
    layout = PrettyTree::Layout::Generic.new([])

    [1, 2, 4, 6].each do |length|
      assert_equal 9, layout.label_anchor([1, 5, 9, 13, 17], length), "for length #{length}"
    end
  end
end

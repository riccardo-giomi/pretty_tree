# frozen_string_literal: true

require "test_helper"

class LayoutBaseTest < Minitest::Test
  def box(lines, anchor)
    PrettyTree::Box.new(lines, lines.first.size, anchor, false)
  end

  def layout(*boxes)
    PrettyTree::Layout::Base.new(boxes)
  end

  def test_gap_separates_merged_boxes
    assert_equal 1, PrettyTree::Layout::GAP
  end

  def test_merge_of_a_single_box_returns_its_lines_unchanged
    lines, width, offsets = layout(box([" a ", " | "], 1)).merge

    assert_equal [" a ", " | "], lines
    assert_equal 3, width
    assert_equal [1], offsets
  end

  def test_merge_places_boxes_side_by_side_separated_by_a_gap
    lines, width, offsets = layout(box(["aaa"], 1), box(["bbb"], 1)).merge

    assert_equal ["aaa bbb"], lines
    assert_equal 7, width
    assert_equal [1, 5], offsets
  end

  def test_merge_does_not_add_a_gap_after_the_last_box
    lines, width, = layout(box(["a"], 0), box(["b"], 0), box(["c"], 0)).merge

    assert_equal ["a b c"], lines
    assert_equal 5, width
  end

  def test_merge_offsets_are_anchors_in_merged_coordinates
    _, _, offsets = layout(box(["  a  "], 2), box(["b"], 0), box(["  c  "], 2)).merge

    assert_equal [2, 6, 10], offsets
  end

  def test_merge_pads_shorter_boxes_with_blank_lines
    lines, width, = layout(box([" a ", " | "], 1), box(["b"], 0)).merge

    assert_equal [" a  b", " |   "], lines
    assert_equal 5, width
  end

  def test_merge_pads_a_shorter_first_box
    lines, = layout(box(["b"], 0), box([" a ", " | "], 1)).merge

    assert_equal ["b  a ", "   | "], lines
  end

  def test_merge_uses_the_tallest_box_as_height
    lines, = layout(box(["a"], 0), box(["b", "b", "b"], 0), box(["c", "c"], 0)).merge

    assert_equal 3, lines.size
  end

  def test_merged_lines_all_have_the_merged_width
    lines, width, = layout(box(["a", "a"], 0), box(["bbb"], 1), box(["cc", "cc", "cc"], 0)).merge

    assert(lines.all? { |line| line.size == width })
  end

  def test_padded_lines_returns_the_box_lines_when_height_matches
    assert_equal [" a ", " | "], layout.padded_lines(box([" a ", " | "], 1), 2)
  end

  def test_padded_lines_adds_blank_lines_as_wide_as_the_box
    assert_equal [" a ", " | ", "   ", "   "], layout.padded_lines(box([" a ", " | "], 1), 4)
  end

  def test_padded_lines_does_not_modify_the_box
    subject = box(["ab"], 0)
    layout.padded_lines(subject, 3)

    assert_equal ["ab"], subject.lines
  end

  def test_render_label_line_centers_odd_label_on_anchor
    assert_equal "   x   ", layout.render_label_line("x", 7, 3)
  end

  def test_render_label_line_centers_even_label_left_of_anchor
    assert_equal "  ab   ", layout.render_label_line("ab", 7, 3)
  end

  def test_render_label_line_is_as_wide_as_requested
    assert_equal 9, layout.render_label_line("abc", 9, 4).size
  end

  def test_render_label_line_of_label_filling_the_width
    assert_equal "abc", layout.render_label_line("abc", 3, 1)
  end

  def test_render_label_line_at_the_left_edge
    assert_equal "ab   ", layout.render_label_line("ab", 5, 1)
  end

  def test_accommodate_parent_label_leaves_children_alone_when_the_label_fits
    lines = [" a ", " | "]
    result = layout.accommodate_parent_label(lines, 3, [1], 1, 3)

    assert_same lines, result[0]
    assert_equal [3, [1], 1], result[1..]
  end

  def test_accommodate_parent_label_leaves_children_alone_for_a_one_character_label
    result = layout.accommodate_parent_label([" a "], 3, [1], 1, 1)

    assert_equal [[" a "], 3, [1], 1], result
  end

  def test_accommodate_parent_label_leaves_children_alone_for_an_empty_label
    result = layout.accommodate_parent_label([" a "], 3, [1], 1, 0)

    assert_equal [[" a "], 3, [1], 1], result
  end

  def test_accommodate_parent_label_pads_the_left_when_the_label_sticks_out_on_the_left
    result = layout.accommodate_parent_label(["x  "], 3, [0], 0, 3)

    assert_equal [[" x  "], 4, [1], 1], result
  end

  def test_accommodate_parent_label_pads_the_right_when_the_label_sticks_out_on_the_right
    result = layout.accommodate_parent_label(["  x"], 3, [2], 2, 5)

    assert_equal [["  x  "], 5, [2], 2], result
  end

  def test_accommodate_parent_label_pads_both_sides_of_a_much_wider_label
    result = layout.accommodate_parent_label(["a b", "c d"], 3, [0, 2], 1, 7)

    assert_equal [["  a b  ", "  c d  "], 7, [2, 4], 3], result
  end

  def test_accommodate_parent_label_pads_every_line_the_same
    lines, width, = layout.accommodate_parent_label(["a  ", "bb ", "ccc"], 3, [0], 0, 9)

    assert_equal 9, width
    assert_equal ["    a    ", "    bb   ", "    ccc  "], lines
  end

  def test_accommodate_parent_label_shifts_every_offset_by_the_left_padding
    _, _, offsets, = layout.accommodate_parent_label(["a b c"], 5, [0, 2, 4], 2, 9)

    assert_equal [2, 4, 6], offsets
  end

  def test_accommodate_parent_label_shifts_the_anchor_by_the_left_padding
    _, _, _, anchor = layout.accommodate_parent_label(["a b"], 3, [0, 2], 1, 7)

    assert_equal 3, anchor
  end

  def test_accommodate_parent_label_keeps_the_anchor_when_nothing_is_padded_on_the_left
    _, _, _, anchor = layout.accommodate_parent_label(["  x"], 3, [2], 2, 5)

    assert_equal 2, anchor
  end

  def test_accommodate_parent_label_pads_even_and_odd_labels_of_similar_width_differently
    even = layout.accommodate_parent_label(["a b"], 3, [0, 2], 1, 4)
    odd = layout.accommodate_parent_label(["a b"], 3, [0, 2], 1, 5)

    assert_equal [[" a b"], 4, [1, 3], 2], even
    assert_equal [[" a b "], 5, [1, 3], 2], odd
  end

  def test_accommodate_parent_label_never_shrinks_the_children
    lines, width, = layout.accommodate_parent_label(["a   b"], 5, [0, 4], 2, 1)

    assert_equal ["a   b"], lines
    assert_equal 5, width
  end

  def test_accommodate_parent_label_does_not_modify_the_lines_it_was_given
    lines = ["a b"]
    layout.accommodate_parent_label(lines, 3, [0, 2], 1, 7)

    assert_equal ["a b"], lines
  end

  def blank_lines(width)
    [" " * width, " " * width]
  end

  def test_render_left_branch_draws_on_both_lines
    lines = layout.render_left_branch(blank_lines(11), "1", 5, [2, 8])

    assert_equal ["    /      ", "   /       "], lines
  end

  def test_render_left_branch_of_far_child_uses_underscores_up_to_the_anchor
    lines = layout.render_left_branch(blank_lines(25), "1", 12, [6, 19])

    assert_equal ["        ____|            ", "       /                 "], lines
  end

  def test_render_left_branch_returns_the_lines_it_was_given
    lines = blank_lines(11)

    assert_same lines, layout.render_left_branch(lines, "1", 5, [2, 8])
  end

  def test_render_right_branch_draws_on_both_lines
    lines = layout.render_right_branch(blank_lines(11), "1", 5, [2, 8])

    assert_equal ["      \\    ", "       \\   "], lines
  end

  def test_render_right_branch_of_far_child_uses_underscores_from_the_anchor
    lines = layout.render_right_branch(blank_lines(25), "1", 12, [6, 19])

    assert_equal ["            |_____       ", "                  \\      "], lines
  end

  def test_render_right_branch_returns_the_lines_it_was_given
    lines = blank_lines(11)

    assert_same lines, layout.render_right_branch(lines, "1", 5, [2, 8])
  end

  def test_render_left_and_right_branches_combine_on_the_same_lines
    lines = layout.render_left_branch(blank_lines(11), "1", 5, [2, 8])
    lines = layout.render_right_branch(lines, "1", 5, [2, 8])

    assert_equal ["    / \\    ", "   /   \\   "], lines
  end

  def test_render_middle_branch_draws_a_bar_on_both_lines
    assert_equal ["  |  ", "  |  "], layout.render_middle_branch(blank_lines(5), 2)
  end

  def test_render_middle_branch_returns_the_lines_it_was_given
    lines = blank_lines(5)

    assert_same lines, layout.render_middle_branch(lines, 2)
  end

  def test_render_middle_branch_combines_with_side_branches
    lines = layout.render_left_branch(blank_lines(11), "1", 5, [1, 9])
    lines = layout.render_middle_branch(lines, 5)
    lines = layout.render_right_branch(lines, "1", 5, [1, 9])

    assert_equal ["   __|__   ", "  /  |  \\  "], lines
  end
end

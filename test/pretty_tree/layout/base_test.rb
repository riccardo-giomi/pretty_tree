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
end

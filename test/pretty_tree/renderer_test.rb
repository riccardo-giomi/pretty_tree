# frozen_string_literal: true

require "test_helper"

class RendererTest < Minitest::Test
  class ArrayAdapterStub
    def value(node) = node.first
    def children(node) = node[1..]
  end

  class InspectFormatterStub
    def label(value, max_width: nil) = value.inspect
  end

  class RecordingFormatterStub
    attr_reader :calls

    def initialize
      @calls = []
    end

    def label(value, max_width: nil)
      @calls << [value, max_width]
      value.inspect
    end
  end

  def array_renderer(**options)
    PrettyTree::Renderer.new(adapter: ArrayAdapterStub.new, formatter: InspectFormatterStub.new, **options)
  end

  def test_box_for_nil_is_empty
    box = array_renderer.box_for(nil)
    assert box.empty?
  end

  def test_box_for_nil_is_a_blank_min_leaf_wide_box
    box = array_renderer.box_for(nil)

    assert_equal ["   "], box.lines
    assert_equal 3, box.width
    assert_equal 1, box.anchor
  end

  def test_box_for_node_with_no_children
    box = array_renderer.box_for(["x"])
    assert_equal ['"x"'], box.lines
    assert_equal 3, box.width
    assert_equal 1, box.anchor
  end

  def test_box_for_node_with_no_children_is_not_empty
    refute array_renderer.box_for(["x"]).empty?
  end

  def test_box_for_node_whose_children_are_all_nil_is_a_leaf
    box = array_renderer.box_for(["x", nil, nil])

    assert_equal ['"x"'], box.lines
    refute box.empty?
  end

  def test_box_for_leaf_pads_short_label_to_min_leaf_size
    box = array_renderer.box_for([1])

    assert_equal [" 1 "], box.lines
    assert_equal 1, box.anchor
  end

  def test_box_for_leaf_keeps_long_label_whole
    box = array_renderer.box_for(["hello"])

    assert_equal ['"hello"'], box.lines
    assert_equal 7, box.width
    assert_equal 3, box.anchor
  end

  def test_box_for_leaf_asks_formatter_for_label_with_default_max_width
    formatter = RecordingFormatterStub.new
    PrettyTree::Renderer.new(adapter: ArrayAdapterStub.new, formatter:).box_for([1])

    assert_equal [[1, PrettyTree::Renderer::LABEL_WIDTH]], formatter.calls
  end

  def test_box_for_leaf_passes_custom_max_width_to_formatter
    formatter = RecordingFormatterStub.new
    PrettyTree::Renderer.new(adapter: ArrayAdapterStub.new, formatter:, max_width: 5).box_for([1])

    assert_equal [[1, 5]], formatter.calls
  end

  def test_box_for_nil_sibling_of_two_takes_no_room
    box = array_renderer.box_for(nil, parent_arity: 2)

    assert_equal [""], box.lines
    assert_equal 0, box.width
    assert box.empty?
  end

  def test_box_for_left_leaf_of_two_has_a_spare_column_on_its_right
    box = array_renderer.box_for([1], parent_arity: 2, position: 0)

    assert_equal [" 1  "], box.lines
    assert_equal 4, box.width
    assert_equal 1, box.anchor
  end

  def test_box_for_right_leaf_of_two_has_a_spare_column_on_its_left
    box = array_renderer.box_for([1], parent_arity: 2, position: 1)

    assert_equal ["  1 "], box.lines
    assert_equal 4, box.width
    assert_equal 2, box.anchor
  end

  def test_box_for_leaf_sibling_of_three_is_padded_to_min_leaf_size
    box = array_renderer.box_for([1], parent_arity: 3)

    assert_equal [" 1 "], box.lines
    assert_equal 3, box.width
  end

  def test_box_for_leaf_with_two_nil_children_is_padded_for_its_own_parent_arity
    box = array_renderer.box_for([1, nil, nil], parent_arity: 1)

    assert_equal [" 1 "], box.lines
  end

  def test_box_for_binary_node_lays_out_label_connectors_and_children
    box = array_renderer.box_for([1, [2], [3]])

    assert_equal ["    1    ", "   / \\   ", "  /   \\  ", " 2     3 "], box.lines
    assert_equal 9, box.width
    assert_equal 4, box.anchor
  end

  def test_box_for_binary_node_with_a_nil_child
    box = array_renderer.box_for([1, [2], nil])

    assert_equal ["    1 ", "   /  ", "  /   ", " 2    "], box.lines
  end

  def test_box_for_binary_node_with_only_nil_children_is_a_leaf
    box = array_renderer.box_for([1, nil, nil])

    assert_equal [" 1 "], box.lines
  end

  def test_box_for_nested_binary_nodes
    box = array_renderer.box_for([1, [2, [4], [5]], [3, [6], [7]]])

    assert_equal [
      "         1         ",
      "      ___|___      ",
      "     /       \\     ",
      "    2         3    ",
      "   / \\       / \\   ",
      "  /   \\     /   \\  ",
      " 4     5   6     7 "
    ], box.lines
  end

  def test_box_for_unary_node_lays_out_label_bar_and_child
    box = array_renderer.box_for([1, [2]])

    assert_equal [" 1 ", " | ", " | ", " 2 "], box.lines
    assert_equal 3, box.width
    assert_equal 1, box.anchor
  end

  def test_box_for_unary_node_with_a_nil_child_is_a_leaf
    assert_equal [" 1 "], array_renderer.box_for([1, nil]).lines
  end

  def test_box_for_chain_of_unary_nodes
    box = array_renderer.box_for([1, [2, [3]]])

    assert_equal [" 1 ", " | ", " | ", " 2 ", " | ", " | ", " 3 "], box.lines
  end

  def test_box_for_only_child_leaf_is_padded_to_min_leaf_size
    box = array_renderer.box_for([1, [2]])

    assert_equal " 2 ", box.lines.last
  end

  def test_box_for_ternary_node_lays_out_label_connectors_and_children
    box = array_renderer.box_for([1, [2], [3], [4]])

    assert_equal ["     1     ", "   / | \\   ", "  /  |  \\  ", " 2   3   4 "], box.lines
    assert_equal 11, box.width
    assert_equal 5, box.anchor
  end

  def test_box_for_ternary_node_with_a_nil_middle_child
    box = array_renderer.box_for([1, [2], nil, [4]])

    assert_equal ["     1     ", "   /   \\   ", "  /     \\  ", " 2       4 "], box.lines
  end

  def test_box_for_ternary_node_with_only_a_middle_child
    box = array_renderer.box_for([1, nil, [3], nil])

    assert_equal ["     1     ", "     |     ", "     |     ", "     3     "], box.lines
  end

  def test_box_for_ternary_node_with_only_nil_children_is_a_leaf
    assert_equal [" 1 "], array_renderer.box_for([1, nil, nil, nil]).lines
  end

  def test_box_for_mixed_unary_binary_and_ternary_nodes
    box = array_renderer.box_for([1, [2, [5]], [3, [6], [7], [8]], [4, [9], [10]]])

    assert_equal [
      "         1               ",
      "   ______|_________      ",
      "  /      |         \\     ",
      " 2       3          4    ",
      " |     / | \\       / \\   ",
      " |    /  |  \\     /   \\  ",
      " 5   6   7   8   9    10 "
    ], box.lines
  end

  def test_box_for_generic_node_lays_out_label_connectors_and_children
    box = array_renderer.box_for([1, [2], [3], [4], [5]])

    assert_equal ["       1       ", "  _____|_____  ", " |   |   |   | ", " 2   3   4   5 "], box.lines
    assert_equal 15, box.width
    assert_equal 7, box.anchor
  end

  def test_box_for_generic_node_ignores_nil_children
    box = array_renderer.box_for([1, [2], nil, [4], nil, [6]])

    assert_equal ["     1     ", "  ___|___  ", " |   |   | ", " 2   4   6 "], box.lines
  end

  def test_box_for_generic_node_with_a_single_child_among_nil_ones
    box = array_renderer.box_for([1, nil, [3], nil, nil])

    assert_equal [" 1 ", " | ", " | ", " 3 "], box.lines
  end

  def test_box_for_generic_node_with_only_nil_children_is_a_leaf
    assert_equal [" 1 "], array_renderer.box_for([1, nil, nil, nil, nil]).lines
  end

  def test_box_for_generic_node_pads_its_leaves_to_the_min_leaf_size
    box = array_renderer.box_for([1, [2], [3], [4], [5]])

    assert_equal " 2   3   4   5 ", box.lines.last
  end

  def test_box_for_generic_node_with_generic_children
    box = array_renderer.box_for([1, [2, [3], [4], [5], [6]], [7]])

    assert_equal [box.width], box.lines.map(&:size).uniq
    assert_equal 7, box.height
  end

  def test_box_for_passes_its_child_count_down_as_parent_arity
    box = array_renderer.box_for([1, [2], [3]])

    assert_equal " 2     3 ", box.lines.last
  end

  def test_box_for_visits_the_node_before_its_children_left_to_right
    formatter = RecordingFormatterStub.new
    PrettyTree::Renderer.new(adapter: ArrayAdapterStub.new, formatter:).box_for([1, [2, [4], [5]], [3]])

    assert_equal [1, 2, 4, 5, 3], formatter.calls.map(&:first)
  end

  def test_box_for_nil_does_not_ask_formatter_for_a_label
    formatter = RecordingFormatterStub.new
    PrettyTree::Renderer.new(adapter: ArrayAdapterStub.new, formatter:).box_for(nil)

    assert_empty formatter.calls
  end
end

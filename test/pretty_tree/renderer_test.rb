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

  def test_box_for_nil_does_not_ask_formatter_for_a_label
    formatter = RecordingFormatterStub.new
    PrettyTree::Renderer.new(adapter: ArrayAdapterStub.new, formatter:).box_for(nil)

    assert_empty formatter.calls
  end
end

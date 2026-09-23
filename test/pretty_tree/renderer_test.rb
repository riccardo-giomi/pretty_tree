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

  def array_renderer
    PrettyTree::Renderer.new(adapter: ArrayAdapterStub.new, formatter: InspectFormatterStub.new)
  end

  def test_stub_box_for_nil_is_an_empty_box
    assert_equal [""], array_renderer.box_for(nil)
  end

  def test_stub_box_for_node_with_no_children
    assert_equal ["\"x\""], array_renderer.box_for(["x"])
  end
end

# frozen_string_literal: true

require "test_helper"

class ArrayTreeTest < Minitest::Test
  def adapter
    PrettyTree::Adapter::ArrayTree.new
  end

  def test_is_a_pretty_tree_adapter
    assert_kind_of PrettyTree::Adapter, adapter
  end

  def test_value_returns_first_element
    assert_equal "a", adapter.value(["a", nil, nil])
  end

  def test_children_returns_remaining_elements
    assert_equal [1, 2], adapter.children(["a", 1, 2])
  end

  def test_children_preserves_nils
    assert_equal [nil, nil], adapter.children(["a", nil, nil])
  end

  def test_children_for_node_with_no_children_slots
    assert_equal [], adapter.children(["a"])
  end
end

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
    assert_equal [[1], [2]], adapter.children(["a", [1], [2]])
  end

  def test_children_preserves_nils
    assert_equal [nil, nil], adapter.children(["a", nil, nil])
  end

  def test_children_for_node_with_no_children_slots
    assert_equal [], adapter.children(["a"])
  end

  def assert_invalid(message_part, &block)
    error = assert_raises(PrettyTree::Error, &block)

    assert_includes error.message, message_part
  end

  def test_value_accepts_a_node_with_no_children_slots
    assert_equal "a", adapter.value(["a"])
  end

  def test_value_rejects_a_string
    assert_invalid("String") { adapter.value("abc") }
  end

  def test_value_rejects_a_number
    assert_invalid("Integer") { adapter.value(5) }
  end

  def test_value_rejects_a_hash
    assert_invalid("Hash") { adapter.value({a: 1}) }
  end

  def test_value_rejects_nil
    assert_raises(PrettyTree::Error) { adapter.value(nil) }
  end

  def test_value_rejects_an_empty_array
    assert_invalid("[]") { adapter.value([]) }
  end

  def test_children_rejects_a_string
    assert_invalid("String") { adapter.children("abc") }
  end

  def test_children_rejects_a_number
    assert_invalid("Integer") { adapter.children(5) }
  end

  def test_children_rejects_an_empty_array
    assert_invalid("[]") { adapter.children([]) }
  end

  def test_children_does_not_print_an_invalid_node
    long = "x" * 1000
    error = assert_raises(PrettyTree::Error) { adapter.children(long) }

    refute_includes error.message, "x" * 50
  end

  def test_children_accepts_arrays_and_nils
    assert_equal [["b"], nil, ["c", nil]], adapter.children(["a", ["b"], nil, ["c", nil]])
  end

  def test_children_rejects_a_child_that_is_not_an_array
    assert_raises(PrettyTree::Error) { adapter.children(["a", "b"]) }
  end

  def test_children_rejects_a_number_among_valid_children
    assert_raises(PrettyTree::Error) { adapter.children(["a", ["b"], 3]) }
  end

  def test_children_rejects_an_empty_array_child
    assert_raises(PrettyTree::Error) { adapter.children(["a", ["b"], []]) }
  end

  def test_children_does_not_print_an_invalid_child
    long = "y" * 1000
    error = assert_raises(PrettyTree::Error) { adapter.children(["a", long]) }

    refute_includes error.message, "y" * 50
  end

  def test_children_does_not_look_inside_the_children
    assert_equal [["b", "not checked here"]], adapter.children(["a", ["b", "not checked here"]])
  end
end

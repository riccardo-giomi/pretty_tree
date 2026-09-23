# frozen_string_literal: true

require "test_helper"

class AdapterTest < Minitest::Test
  def setup
    @adapter = PrettyTree::Adapter.new
  end

  def test_value_is_not_implemented
    assert_raises(NotImplementedError) { @adapter.value(:node) }
  end

  def test_children_is_not_implemented
    assert_raises(NotImplementedError) { @adapter.children(:node) }
  end
end

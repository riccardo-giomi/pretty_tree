# frozen_string_literal: true

require "test_helper"

class FormatterTest < Minitest::Test
  def test_label_is_not_implemented
    assert_raises(NotImplementedError) { PrettyTree::Formatter.new.label(:value) }
  end
end

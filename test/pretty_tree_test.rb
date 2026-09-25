# frozen_string_literal: true

require "test_helper"

class TestPrettyTree < Minitest::Test
  class HashAdapterStub
    def value(node) = node[:label]
    def children(node) = node[:kids]
  end

  class ReverseFormatterStub
    def label(value, max_width: nil) = value.to_s.reverse
  end

  def render_lines(lines)
    lines.join("\n")
  end

  def test_that_it_has_a_version_number
    refute_nil ::PrettyTree::VERSION
  end

  def test_renders_nil_as_empty_string
    assert_equal "   ", PrettyTree.render(nil)
  end

  def test_renders_single_node_as_string
    assert_equal '"a"', PrettyTree.render(["a", nil, nil])
  end

  def test_long_node_values_are_truncated
    assert_equal "\"morethan...", PrettyTree.render(["morethan10chars"])
  end

  def test_renders_a_single_branch_tree
    expected_lines = [
      " 1 ",
      " | ",
      " | ",
      " 2 "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2, nil]])
  end

  def test_renders_a_simple_balanced_binary_tree
    expected_lines = [
      "     1     ",
      "    / \\    ",
      "   /   \\   ",
      "  2     3  "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2, nil, nil], [3, nil, nil]])
  end

  def test_renders_a_left_unbalanced_binary_tree
    expected_lines = [
      "     1     ",
      "    /      ",
      "   /       ",
      "  2        "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2, nil, nil], nil])
  end

  def test_renders_a_right_unbalanced_binary_tree
    expected_lines = [
      "     1     ",
      "      \\    ",
      "       \\   ",
      "        3  "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, nil, [3, nil, nil]])
  end

  def test_renders_a_left_leaning_chain
    expected_lines = [
      "        1        ",
      "       /         ",
      "      /          ",
      "     2           ",
      "    /            ",
      "   /             ",
      "  3              "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2, [3, nil, nil], nil], nil])
  end

  def test_renders_a_right_leaning_chain
    expected_lines = [
      "        1        ",
      "         \\       ",
      "          \\      ",
      "           2     ",
      "            \\    ",
      "             \\   ",
      "              3  "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, nil, [2, nil, [3, nil, nil]]])
  end

  def test_renders_a_full_binary_tree_of_three_levels
    expected_lines = [
      "           1           ",
      "       ____|____       ",
      "      /         \\      ",
      "     2           3     ",
      "    / \\         / \\    ",
      "   /   \\       /   \\   ",
      "  4     5     6     7  "
    ]
    tree = [1, [2, [4, nil, nil], [5, nil, nil]], [3, [6, nil, nil], [7, nil, nil]]]

    assert_equal render_lines(expected_lines), PrettyTree.render(tree)
  end

  def test_renders_string_values_inspected
    expected_lines = [
      "          \"c\"          ",
      "       ____|____       ",
      "      /         \\      ",
      "    \"b\"         \"d\"    ",
      "    /           / \\    ",
      "   /           /   \\   ",
      " \"a\"         \"e\"   \"f\" "
    ]
    tree = ["c", ["b", ["a", nil, nil], nil], ["d", ["e", nil, nil], ["f", nil, nil]]]

    assert_equal render_lines(expected_lines), PrettyTree.render(tree)
  end

  def test_renders_far_apart_children_with_underscore_connectors
    expected_lines = [
      "            1            ",
      "        ____|_____       ",
      "       /          \\      ",
      "\"wwwwwwww... \"vvvvvvvv..."
    ]
    tree = [1, ["wwwwwwwwwwww", nil, nil], ["vvvvvvvvvvvv", nil, nil]]

    assert_equal render_lines(expected_lines), PrettyTree.render(tree)
  end

  def test_renders_a_chain_of_single_children
    expected_lines = [
      " 1 ",
      " | ",
      " | ",
      " 2 ",
      " | ",
      " | ",
      " 3 "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2, [3]]])
  end

  def test_renders_a_single_child_with_two_children_of_its_own
    expected_lines = [
      "     1     ",
      "     |     ",
      "     |     ",
      "     2     ",
      "    / \\    ",
      "   /   \\   ",
      "  3     4  "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2, [3, nil, nil], [4, nil, nil]]])
  end

  def test_renders_a_full_ternary_tree
    expected_lines = [
      "     1     ",
      "   / | \\   ",
      "  /  |  \\  ",
      " 2   3   4 "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2, nil, nil, nil], [3, nil, nil, nil], [4, nil, nil, nil]])
  end

  def test_renders_a_ternary_tree_with_only_a_middle_child
    expected_lines = [
      "     1     ",
      "     |     ",
      "     |     ",
      "     3     "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, nil, [3, nil, nil, nil], nil])
  end

  def test_renders_a_ternary_tree_without_a_middle_child
    expected_lines = [
      "     1     ",
      "   /   \\   ",
      "  /     \\  ",
      " 2       4 "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2, nil, nil, nil], nil, [4, nil, nil, nil]])
  end

  def test_renders_a_tree_mixing_one_two_and_three_children
    expected_lines = [
      "         1                 ",
      "   ______|__________       ",
      "  /      |          \\      ",
      " 2       3           4     ",
      " |     / | \\        / \\    ",
      " |    /  |  \\      /   \\   ",
      " 5   6   7   8    9    10  "
    ]
    tree = [1, [2, [5]], [3, [6], [7], [8]], [4, [9], [10]]]

    assert_equal render_lines(expected_lines), PrettyTree.render(tree)
  end

  def test_renders_a_label_wider_than_its_single_child
    expected_lines = [
      "123456789012",
      "      |     ",
      "      |     ",
      "      1     "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([123456789012, [1]])
  end

  def test_renders_a_label_wider_than_its_two_children
    expected_lines = [
      "123456789012",
      "     / \\    ",
      "    /   \\   ",
      "   1     2  "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([123456789012, [1], [2]])
  end

  def test_renders_a_label_wider_than_its_three_children
    expected_lines = [
      "123456789012",
      "    / | \\   ",
      "   /  |  \\  ",
      "  1   2   3 "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([123456789012, [1], [2], [3]])
  end

  def test_renders_a_wide_label_with_an_odd_number_of_characters
    expected_lines = [
      "  1234567  ",
      "   / | \\   ",
      "  /  |  \\  ",
      " 1   2   3 "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1234567, [1], [2], [3]])
  end

  def test_renders_a_wide_label_on_a_missing_child_side
    expected_lines = [
      "123456789012",
      "     /      ",
      "    /       ",
      "   1        "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([123456789012, [1], nil])
  end

  def test_renders_a_wide_label_deeper_in_the_tree
    expected_lines = [
      "        1         ",
      "        |_____    ",
      "       /      \\   ",
      "123456789012   4  ",
      "     / \\          ",
      "    /   \\         ",
      "   2     3        "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [123456789012, [2], [3]], [4]])
  end

  def test_renders_two_children_that_each_have_a_single_child
    expected_lines = [
      "     1     ",
      "    / \\    ",
      "   /   \\   ",
      "  2     4  ",
      "  |     |  ",
      "  |     |  ",
      "  3     5  "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2, [3]], [4, [5]]])
  end

  def test_renders_two_children_with_single_children_of_different_heights
    expected_lines = [
      "     1     ",
      "    / \\    ",
      "   /   \\   ",
      "  2     5  ",
      "  |     |  ",
      "  |     |  ",
      "  3     6  ",
      "  |        ",
      "  |        ",
      "  4        "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2, [3, [4]]], [5, [6]]])
  end

  def test_renders_a_ternary_tree_of_ternary_trees_with_tight_connectors_everywhere
    expected_lines = [
      "                 1                 ",
      "       __________|__________       ",
      "      /          |          \\      ",
      "     2           6          10     ",
      "   / | \\       / | \\       / | \\   ",
      "  /  |  \\     /  |  \\     /  |  \\  ",
      " 3   4   5   7   8   9  11  12  13 "
    ]
    tree = [
      1,
      [2, [3, nil, nil], [4, nil, nil], [5, nil, nil]],
      [6, [7, nil, nil], [8, nil, nil], [9, nil, nil]],
      [10, [11, nil, nil], [12, nil, nil], [13, nil, nil]]
    ]

    assert_equal render_lines(expected_lines), PrettyTree.render(tree)
  end

  def test_render_pads_every_line_to_the_same_width
    tree = [1, [2, [4, nil, nil], nil], [3, nil, [5, nil, nil]]]
    widths = PrettyTree.render(tree).lines.map { |line| line.chomp.size }

    assert_equal 1, widths.uniq.size
  end

  def test_print_writes_a_multiline_tree_to_stdout
    out, _err = capture_io { PrettyTree.print([1, [2, nil, nil], [3, nil, nil]]) }

    assert_equal render_lines(["     1     ", "    / \\    ", "   /   \\   ", "  2     3  "]) + "\n", out
  end

  def test_print_writes_render_output_to_stdout_with_trailing_newline
    out, _err = capture_io { PrettyTree.print(["x"]) }
    assert_equal '"x"' + "\n", out
  end

  def test_print_forwards_adapter_and_formatter_arguments
    tree = {label: "cat", kids: []}

    out, _err = capture_io do
      PrettyTree.print(tree, adapter: HashAdapterStub.new, formatter: ReverseFormatterStub.new)
    end

    assert_equal "tac\n", out
  end
end

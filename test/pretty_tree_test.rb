# frozen_string_literal: true

require "test_helper"

class TestPrettyTree < Minitest::Test
  class HashAdapterStub
    def value(node) = node[:label]
    def children(node) = node[:kids]
  end

  class InspectFormatterStub
    def label(value, max_width: nil) = value.inspect
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
      "    1    ",
      "   / \\   ",
      "  /   \\  ",
      " 2     3 "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2, nil, nil], [3, nil, nil]])
  end

  def test_renders_a_left_unbalanced_binary_tree
    expected_lines = [
      "    1 ",
      "   /  ",
      "  /   ",
      " 2    "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2, nil, nil], nil])
  end

  def test_renders_a_right_unbalanced_binary_tree
    expected_lines = [
      " 1    ",
      "  \\   ",
      "   \\  ",
      "    3 "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, nil, [3, nil, nil]])
  end

  def test_renders_a_left_leaning_chain
    expected_lines = [
      "       1 ",
      "      /  ",
      "     /   ",
      "    2    ",
      "   /     ",
      "  /      ",
      " 3       "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2, [3, nil, nil], nil], nil])
  end

  def test_renders_a_right_leaning_chain
    expected_lines = [
      " 1       ",
      "  \\      ",
      "   \\     ",
      "    2    ",
      "     \\   ",
      "      \\  ",
      "       3 "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, nil, [2, nil, [3, nil, nil]]])
  end

  def test_renders_a_full_binary_tree_of_three_levels
    expected_lines = [
      "         1         ",
      "      ___|___      ",
      "     /       \\     ",
      "    2         3    ",
      "   / \\       / \\   ",
      "  /   \\     /   \\  ",
      " 4     5   6     7 "
    ]
    tree = [1, [2, [4, nil, nil], [5, nil, nil]], [3, [6, nil, nil], [7, nil, nil]]]

    assert_equal render_lines(expected_lines), PrettyTree.render(tree)
  end

  def test_renders_string_values_inspected
    expected_lines = [
      "      \"c\"       ",
      "      /  \\      ",
      "     /    \\     ",
      "   \"b\"    \"d\"   ",
      "   /      / \\   ",
      "  /      /   \\  ",
      "\"a\"    \"e\"   \"f\""
    ]
    tree = ["c", ["b", ["a", nil, nil], nil], ["d", ["e", nil, nil], ["f", nil, nil]]]

    assert_equal render_lines(expected_lines), PrettyTree.render(tree)
  end

  def test_renders_far_apart_children_with_underscore_connectors
    expected_lines = [
      "             1             ",
      "        _____|______       ",
      "       /            \\      ",
      "\"wwwwwwww...   \"vvvvvvvv..."
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
      "    1    ",
      "    |    ",
      "    |    ",
      "    2    ",
      "   / \\   ",
      "  /   \\  ",
      " 3     4 "
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
      "         1               ",
      "   ______|_________      ",
      "  /      |         \\     ",
      " 2       3          4    ",
      " |     / | \\       / \\   ",
      " |    /  |  \\     /   \\  ",
      " 5   6   7   8   9    10 "
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
      "          1      ",
      "        / |___   ",
      "       /      \\  ",
      "123456789012   4 ",
      "     / \\         ",
      "    /   \\        ",
      "   2     3       "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [123456789012, [2], [3]], [4]])
  end

  def test_renders_two_children_that_each_have_a_single_child
    expected_lines = [
      "    1    ",
      "   / \\   ",
      "  /   \\  ",
      " 2     4 ",
      " |     | ",
      " |     | ",
      " 3     5 "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2, [3]], [4, [5]]])
  end

  def test_renders_two_children_with_single_children_of_different_heights
    expected_lines = [
      "    1    ",
      "   / \\   ",
      "  /   \\  ",
      " 2     5 ",
      " |     | ",
      " |     | ",
      " 3     6 ",
      " |       ",
      " |       ",
      " 4       "
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

  def test_renders_a_node_with_four_children
    expected_lines = [
      "       1       ",
      "  _____|_____  ",
      " |   |   |   | ",
      " 2   3   4   5 "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2], [3], [4], [5]])
  end

  def test_renders_a_node_with_six_children
    expected_lines = [
      "           1           ",
      "  _________|_________  ",
      " |   |   |   |   |   | ",
      " 2   3   4   5   6   7 "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2], [3], [4], [5], [6], [7]])
  end

  def test_renders_a_node_with_many_children_ignoring_the_missing_ones
    expected_lines = [
      "     1     ",
      "  ___|___  ",
      " |   |   | ",
      " 2   4   6 "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2], nil, [4], nil, [6]])
  end

  def test_renders_a_node_with_many_slots_and_a_single_child
    expected_lines = [
      " 1 ",
      " | ",
      " | ",
      " 3 "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, nil, [3], nil, nil])
  end

  def test_renders_a_wide_label_over_four_children
    expected_lines = [
      " \"a-very-l...  ",
      "  _____|_____  ",
      " |   |   |   | ",
      " 2   3   4   5 "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render(["a-very-long-root-label", [2], [3], [4], [5]])
  end

  def test_renders_a_node_with_four_children_as_the_left_child_of_a_binary_node
    expected_lines = [
      "            1       ",
      "         ___|____   ",
      "        /        \\  ",
      "       2          7 ",
      "  _____|_____       ",
      " |   |   |   |      ",
      " 3   4   5   6      "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2, [3], [4], [5], [6]], [7]])
  end

  def test_renders_a_node_with_four_children_as_the_right_child_of_a_binary_node
    expected_lines = [
      "      1             ",
      "   ___|____         ",
      "  /        \\        ",
      " 7          2       ",
      "       _____|_____  ",
      "      |   |   |   | ",
      "      3   4   5   6 "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [7], [2, [3], [4], [5], [6]]])
  end

  def test_renders_a_node_with_four_children_as_the_middle_child_of_a_ternary_node
    expected_lines = [
      "           1           ",
      "   ________|________   ",
      "  /        |        \\  ",
      " 8         2         9 ",
      "      _____|_____      ",
      "     |   |   |   |     ",
      "     3   4   5   6     "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [8], [2, [3], [4], [5], [6]], [9]])
  end

  def test_renders_nodes_with_many_children_inside_a_node_with_many_children
    expected_lines = [
      "                            1          ",
      "        ____________________|________  ",
      "       |               |         |   | ",
      "       2               7        12  13 ",
      "  _____|_____     _____|_____          ",
      " |   |   |   |   |   |   |   |         ",
      " 3   4   5   6   8   9  10  11         "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([1, [2, [3], [4], [5], [6]], [7, [8], [9], [10], [11]], [12], [13]])
  end

  def test_renders_four_ternary_subtrees_under_one_root
    expected_lines = [
      "                    \"root\"                     ",
      "      _________________|_________________      ",
      "     |           |           |           |     ",
      "     1           2           3           4     ",
      "   / | \\       / | \\       / | \\       / | \\   ",
      "  /  |  \\     /  |  \\     /  |  \\     /  |  \\  ",
      "\"a\" \"b\" \"c\" \"a\" \"b\" \"c\" \"a\" \"b\" \"c\" \"a\" \"b\" \"c\"",
      " |   |   |   |   |   |   |   |   |   |   |   | ",
      " |   |   |   |   |   |   |   |   |   |   |   | ",
      "\"A\" \"B\" \"C\" \"A\" \"B\" \"C\" \"A\" \"B\" \"C\" \"A\" \"B\" \"C\""
    ]
    tree = ["root", [1, ["a", ["A"]], ["b", ["B"]], ["c", ["C"]]], [2, ["a", ["A"]], ["b", ["B"]], ["c", ["C"]]], [3, ["a", ["A"]], ["b", ["B"]], ["c", ["C"]]], [4, ["a", ["A"]], ["b", ["B"]], ["c", ["C"]]]]

    assert_equal render_lines(expected_lines), PrettyTree.render(tree)
  end

  def test_renders_every_line_of_a_tree_with_many_children_with_the_same_width
    tree = [1, [2, [3], [4], [5], [6]], [7, [8], nil, [10]], [11], nil, [13]]
    widths = PrettyTree.render(tree).lines.map { |line| line.chomp.size }

    assert_equal 1, widths.uniq.size
  end

  def test_render_pads_every_line_to_the_same_width
    tree = [1, [2, [4, nil, nil], nil], [3, nil, [5, nil, nil]]]
    widths = PrettyTree.render(tree).lines.map { |line| line.chomp.size }

    assert_equal 1, widths.uniq.size
  end

  def test_print_writes_a_multiline_tree_to_stdout
    out, _err = capture_io { PrettyTree.print([1, [2, nil, nil], [3, nil, nil]]) }

    assert_equal render_lines(["    1    ", "   / \\   ", "  /   \\  ", " 2     3 "]) + "\n", out
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

  def test_render_raises_a_pretty_tree_error_for_a_string
    error = assert_raises(PrettyTree::Error) { PrettyTree.render("abc") }
    assert_includes error.message, "String"
  end

  def test_render_raises_a_pretty_tree_error_for_a_number
    assert_raises(PrettyTree::Error) { PrettyTree.render(5) }
  end

  def test_render_raises_a_pretty_tree_error_for_an_empty_array
    assert_raises(PrettyTree::Error) { PrettyTree.render([]) }
  end

  def test_render_raises_a_pretty_tree_error_for_a_child_that_is_not_an_array
    assert_raises(PrettyTree::Error) { PrettyTree.render(["a", "b"]) }
  end

  def test_render_raises_a_pretty_tree_error_for_an_empty_array_child
    assert_raises(PrettyTree::Error) { PrettyTree.render(["a", []]) }
  end

  def test_render_raises_a_pretty_tree_error_for_an_invalid_node_deep_in_the_tree
    assert_raises(PrettyTree::Error) { PrettyTree.render([1, [2, [3, 4]], nil]) }
  end

  def test_print_raises_and_prints_nothing_for_an_invalid_tree
    out, _err = capture_io do
      assert_raises(PrettyTree::Error) { PrettyTree.print("abc") }
    end

    assert_empty out
  end

  def test_validation_errors_are_rescuable_as_standard_error
    assert_raises(StandardError) { PrettyTree.render(["a", 1]) }
  end

  def test_render_still_accepts_nil_children_and_a_nil_tree
    assert_equal "   ", PrettyTree.render(nil)
    assert_equal '"a"', PrettyTree.render(["a", nil, nil])
  end

  def test_validation_does_not_apply_to_a_custom_adapter
    tree = {label: "cat", kids: []}

    assert_equal "tac", PrettyTree.render(tree, adapter: HashAdapterStub.new, formatter: ReverseFormatterStub.new)
  end

  def test_render_works_with_a_custom_adapter_over_non_array_nodes
    tree = {label: "a", kids: [{label: "b", kids: []}, {label: "c", kids: [{label: "d", kids: []}, nil]}]}
    expected = ["    \"a\"    ", "   /   \\   ", "  /     \\  ", "\"b\"     \"c\"", "        /  ", "       /   ", "     \"d\"   "]

    assert_equal expected.join("\n"), PrettyTree.render(tree, adapter: HashAdapterStub.new, formatter: InspectFormatterStub.new)
  end

  def test_renders_an_even_length_label_centered_on_its_connectors
    expected_lines = [
      "     \"root\"    ",
      "     /    \\    ",
      "    /      \\   ",
      "\"aaaa\"   \"bbbb\""
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render(["root", ["aaaa", nil, nil], ["bbbb", nil, nil]])
  end

  def test_renders_a_k_d_tree_with_even_length_labels_on_both_levels
    expected_lines = [
      "            [7, 2]       ",
      "          _____|_____    ",
      "         /           \\   ",
      "     [5, 4]        [9, 6]",
      "     /    \\          /   ",
      "    /      \\        /    ",
      "[2, 3]   [4, 7] [8, 1]   "
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([[7, 2], [[5, 4], [[2, 3], nil, nil], [[4, 7], nil, nil]], [[9, 6], [[8, 1], nil, nil], nil]])
  end

  def test_renders_a_k_d_tree_with_a_full_right_subtree
    expected_lines = [
      "              [7, 2]              ",
      "          _______|______          ",
      "         /              \\         ",
      "     [5, 4]           [10, 6]     ",
      "     /    \\           /     \\     ",
      "    /      \\         /       \\    ",
      "[2, 3]   [4, 7] [12, 21]   [1, 35]"
    ]
    assert_equal render_lines(expected_lines), PrettyTree.render([[7, 2], [[5, 4], [[2, 3], nil, nil], [[4, 7], nil, nil]], [[10, 6], [[12, 21], nil, nil], [[1, 35], nil, nil]]])
  end
end

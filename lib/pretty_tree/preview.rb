# frozen_string_literal: true

module PrettyTree
  class Preview
    def initialize(...)
      @renderer = Renderer.new(...)
    end

    def render(tree)
      puts
      puts tree.inspect
      puts
      puts @renderer.call(tree)
      puts
    end

    def run
      render(nil)
      render(["a"])
      render(["morethan10chars"])
      render([1, [2, nil, nil]])
      render([1, [2, [3, nil, nil]]])
      render(["a", ["b", nil, nil], nil])
      render(["a", nil, ["c", nil, nil]])
      render(["a", ["b", nil, nil], ["c", nil, nil]])
      render([1, [2, [3, [4]]], [5, [6]]])
      render(["a", ["b", nil, nil], ["c", nil, nil], ["d", nil, nil]])
      render([1, ["a", ["b", nil, nil], ["c", nil, nil], ["d", nil, nil]], nil])
      render([1, nil, ["a", ["b", nil, nil], ["c", nil, nil], ["d", nil, nil]]])
      render([1, nil, ["a", ["b", nil, nil], ["c", nil, nil], ["d", nil, nil]], nil])
      render([123456789012, [2, nil, nil], [6, nil, nil], [7, nil, nil]])
      render([1, ["a", ["b", nil, nil], ["c", nil, nil]], ["d", ["e", nil, nil], ["f", nil, nil]]])
      render([1, ["a", ["b", nil, nil], ["c", nil, nil], ["d", nil, nil]], ["e", ["f", nil, nil], ["g", nil, nil], ["h", nil, nil]]])
      render([1, [2, [3, nil, nil], [4, nil, nil], [5, nil, nil]], [6, [7, nil, nil], [8, nil, nil], [9, nil, nil]], [10, [11, nil, nil], [12, nil, nil], [13, nil, nil]]])
      render([1, [2, nil, nil], [6, [7, nil, nil], [8, nil, nil], [9, nil, nil]], [10, [11, nil, nil], [12, nil, nil], [13, nil, nil]]])
      render([1337, ["aaaa", ["bbbb", nil, nil], ["cccc", nil, nil], ["dddd", nil, nil]], ["eeee", ["ffff", nil, nil], ["gggg", nil, nil], ["hhhh", nil, nil]]])
      render(["a" * 1, ["b" * 10, nil, nil], ["c" * 10, nil, nil]])
      render(["a" * 10, ["b" * 10, nil, nil], ["c" * 10, nil, nil]])
      render(["a" * 1, ["b" * 10, ["c" * 10, nil, nil], ["d" * 10, nil, nil]], ["e" * 10, ["f" * 10, nil, nil], ["g" * 10, nil, nil]]])
      render(["a" * 10, ["b" * 10, ["c" * 10, nil, nil], ["d" * 10, nil, nil]], ["e" * 10, ["f" * 10, nil, nil], ["g" * 10, nil, nil]]])
      render(["root", ["leftlongsubtree", ["a", nil, nil], ["b", nil, nil]], ["r", nil, nil]])
      render(["root", ["l", nil, nil], ["rightlongsubtree", ["a", nil, nil], ["b", nil, nil]]])
      render(["root", ["leftlongsubtree", ["a", nil, nil], ["b", nil, nil]], ["m", nil, nil], ["rightlongsubtree", ["c", nil, nil], ["d", nil, nil]]])
      render([786494, ["dvy", nil, nil, ["", nil, [true, nil, nil], ["cmv", nil]]]])
      render(["root", [1, nil, nil, nil, nil]])
      render(["root", [1, nil, nil, nil, nil], [2, nil, nil, nil, nil], [3, nil, nil, nil, nil], [4, nil, nil, nil, nil]])
      render(["root", [1, ["a", ["A"]], ["b", ["B"]], ["c", ["C"]]], [2, ["a", ["A"]], ["b", ["B"]], ["c", ["C"]]], [3, ["a", ["A"]], ["b", ["B"]], ["c", ["C"]]], [4, ["a", ["A"]], ["b", ["B"]], ["c", ["C"]]]])
      render(["root", [1, nil, nil, nil, nil, nil], [2, nil, nil, nil, nil, nil], [3, nil, nil, nil, nil, nil], [4, nil, nil, nil, nil, nil], [5, nil, nil, nil, nil, nil]])
      render(["root", [1, ["a", ["A"]], ["b", ["B"]], ["c", ["C"]]], [2, ["a", ["A"]], ["b", ["B"]], ["c", ["C"]]], [3, ["a", ["A"]], ["b", ["B"]], ["c", ["C"]]], [4, ["a", ["A"]], ["b", ["B"]], ["c", ["C"]]], [5, ["a", ["A"]], ["b", ["B"]], ["c", ["C"]]]])
    end
  end
end

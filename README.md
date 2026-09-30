# PrettyTree

Pretty-print tree-shaped data as readable ASCII diagrams — for `#inspect` output, log lines, or debugging.

```ascii
                 1
       __________|__________
      /          |          \
     2           6          10
   / | \       / | \       / | \
  /  |  \     /  |  \     /  |  \
 3   4   5   7   8   9  11  12  13
```

## Installation

```bash
bundle add pretty_tree
```

Or, without Bundler:

```bash
gem install pretty_tree
```

## Usage

Out of the box, PrettyTree understands nested arrays, where each node is
`[value, *children]` and `nil` marks an empty child slot:

```ruby
require "pretty_tree"

tree = ["a", ["b", nil, nil], ["c", ["d", nil, nil], nil]]

PrettyTree.print(tree)
# =>
#    "a"
#   /   \
#  /     \
#"b"     "c"
#        /
#       /
#     "d"
```

`PrettyTree.render(tree)` returns the diagram as a `String` instead of printing
it, for use in `#inspect` or logging:

```ruby
def inspect
  PrettyTree.render(self)
end
```

### Preview

`PrettyTree.preview` will print a collection of example trees as a preview, call it from `irb` or a script:

```ruby
require "pretty_tree"

PrettyTree.preview
```

### Custom node types

Any tree shape can be rendered by providing an `Adapter` — an object that knows how to read a node's value and children:

```ruby
class MyAdapter < PrettyTree::Adapter
  def value(node) = node.name
  def children(node) = node.kids
end

PrettyTree.render(my_tree, adapter: MyAdapter.new)
```

An adapter must follow this contract:

- `value(node)` returns the node's value: any object your `Formatter` can turn
  into a label.
- `children(node)` returns an object that responds to `#each` (an `Array`, a
  `Set`, an `Enumerator`, any `Enumerable`), and never `nil`. It yields the
  node's children in order, from left to right. Use `nil` for an empty slot: a
  slot keeps its position, so `[left, nil]` and `[nil, right]` are different
  trees. No children, or only `nil`s, makes the node a leaf.
- The adapter is never called with `nil`: an empty slot is drawn as empty space
  without asking the adapter about it.
- Anything else is up to the adapter. PrettyTree does not look at the children
  themselves, only at what `children` returns, and raises `PrettyTree::Error`
  if that does not respond to `#each`.

A `Formatter` controls how a value is turned into a label (defaults to
`#inspect`). `label` receives the value and a `max_width:` keyword, which it can
use to shorten long labels, and returns the label; whatever it returns is
converted with `to_s`:

```ruby
class MyFormatter < PrettyTree::Formatter
  def label(value, max_width: nil) = value.to_s.upcase
end

PrettyTree.render(my_tree, formatter: MyFormatter.new)
```

The structure must be a tree: PrettyTree does not detect cycles, so an adapter
whose `children` leads back to an ancestor raises `SystemStackError`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, then run
`bundle exec rake release`.

`rake preview` will call `PrettyTree.preview`.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/riccardo-giomi/pretty_tree.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).

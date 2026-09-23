# PrettyTree

Pretty-print tree-shaped data as readable ASCII diagrams — for `#inspect` output, log lines, or debugging.

```ascii
   "a"
   / \
  /   \
"b"   "c"
     /
    /
  "d"
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
#    / \
#   /   \
# "b"   "c"
#      /
#     /
#   "d"
```

`PrettyTree.render(tree)` returns the diagram as a `String` instead of printing
it, for use in `#inspect` or logging:

```ruby
def inspect
  PrettyTree.render(self)
end
```

### Custom node types

Any tree shape can be rendered by providing an `Adapter` — an object that knows how to read a node's value and children:

```ruby
class MyAdapter < PrettyTree::Adapter
  def value(node) = node.name
  def children(node) = node.kids # nil entries mark empty slots
end

PrettyTree.render(my_tree, adapter: MyAdapter.new)
```

A `Formatter` controls how a value is turned into a label (defaults to `#inspect`):

```ruby
class MyFormatter < PrettyTree::Formatter
  def label(value) = value.to_s.upcase
end

PrettyTree.render(my_tree, formatter: MyFormatter.new)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, then run
`bundle exec rake release`.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/riccardo-giomi/pretty_tree.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).

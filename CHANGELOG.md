# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-09-30

### Added

- `PrettyTree.render` and `PrettyTree.print` draw a tree as an ASCII diagram.
- Layouts for nodes with one, two, three or more children, with `nil` marking an
  empty slot.
- `Adapter` interface for rendering any node type, with a default `ArrayTree`
  adapter for nested arrays.
- `Formatter` interface for labels, with a default formatter that uses `#inspect`
  and truncates long labels.
- `PrettyTree.preview` prints example trees.
- `PrettyTree::Error` is raised for invalid nested-array trees.

[Unreleased]: https://github.com/riccardo-giomi/pretty_tree/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/riccardo-giomi/pretty_tree/releases/tag/v0.1.0

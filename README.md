# edit_distance

[![Package Version](https://img.shields.io/hexpm/v/edit_distance)](https://hex.pm/packages/edit_distance)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/edit_distance/)

📝 A pure Gleam package to compute the
[edit distance](https://en.wikipedia.org/wiki/Edit_distance) of two strings.

## Usage

To add this package to your Gleam project:

```sh
gleam add edit_distance
```

And you're good to start using it!

```gleam
import edit_distance
assert 2 == edit_distance.levenshtein("gleam", "beam")
```

## Contributing

If you think there's any way to improve this package, or if you spot a bug don't
be afraid to open PRs, issues or requests of any kind!
Any contribution is welcome 💜

## Aknowledgments

Credits for the Levenshtein distance implementation go to the
[Levenshtein](https://github.com/preciz/levenshtein) Elixir library!

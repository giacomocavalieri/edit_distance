# edit_distance

[![Package Version](https://img.shields.io/hexpm/v/edit_distance)](https://hex.pm/packages/edit_distance)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/edit_distance/)
![CI](https://github.com/giacomocavalieri/edit_distance/workflows/CI/badge.svg?branch=main)

A pure Gleam package to compute the [edit distance](https://en.wikipedia.org/wiki/Edit_distance) of two strings 📝

> ⚙️ This package supports the Erlang and JavaScript targets!

## Installation

To add this package to your Gleam project:

```sh
gleam add edit_distance
```

## Usage

To use the package, you can import the module corresponding to one of the metrics and call the `distance` function. For example, to compute the edit distance of two strings using the Levenshtein distance you can:

```gleam
import edit_distance/levenshtein
levenshtein.distance("gleam", "beam")
// -> 2
```

## Future plans

For now the only implemented algorithm is the [Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance), but I'd like to add more: for sure the [Damerau-Levenshtein distance](https://en.wikipedia.org/wiki/Damerau–Levenshtein_distance) would be a useful future addition!

## Contributing

If you think there's any way to improve this package, or if you spot a bug don't be afraid to open PRs, issues or requests of any kind! Any contribution is welcome 💜

## Aknowledgments

Credits for the Levenshtein distance implementation go to the [Levenshtein](https://github.com/preciz/levenshtein) Elixir library!

import gleam/int
import gleam/list
import gleam/string

/// Compute the edit distance between two strings using the
/// [Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance).
///
/// ## Examples
///
/// ```gleam
/// > distance("gleam", "beam")
/// 2
/// ```
///
/// ```gleam
/// > distance("cat", "cap")
/// 1
/// ```
///
pub fn levenshtein(one: String, other: String) -> Int {
  case one, other {
    _, _ if one == other -> 0
    "", string | string, "" -> string.length(string)
    one, other -> {
      let one = string.to_graphemes(one)
      let other = string.to_graphemes(other)
      let distance_list = list.range(0, list.length(other))
      levenshtein_loop(one, other, distance_list, 1)
    }
  }
}

fn levenshtein_loop(
  one: List(String),
  other: List(String),
  distance_list: List(Int),
  step: Int,
) -> Int {
  case one {
    [] -> {
      let assert Ok(last_distance) = list.last(distance_list)
        as "distance list will always have at least one item"
      last_distance
    }

    [first, ..rest] -> {
      let distance_list =
        update_distance_list(other, distance_list, first, step, [step])

      levenshtein_loop(rest, other, distance_list, step + 1)
    }
  }
}

fn update_distance_list(
  other: List(String),
  distances: List(Int),
  grapheme: String,
  last_distance: Int,
  acc: List(Int),
) -> List(Int) {
  case other {
    [] -> list.reverse(acc)
    [first, ..rest] -> {
      let assert [first_dist, ..rest_dist] = distances

      let difference = case grapheme == first {
        False -> 1
        True -> 0
      }

      let min = case rest_dist {
        [] -> int.min(first_dist + difference, last_distance + 1)
        [second_dist, ..] ->
          int.min(first_dist + difference, last_distance + 1)
          |> int.min(second_dist + 1)
      }

      update_distance_list(rest, rest_dist, grapheme, min, [min, ..acc])
    }
  }
}

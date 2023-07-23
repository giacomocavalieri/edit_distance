import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn distance(one: String, other: String) -> Int {
  case one, other {
    _, _ if one == other -> 0
    "", string | string, "" -> string.length(string)
    one, other -> {
      let one = string.to_graphemes(one)
      let other = string.to_graphemes(other)
      let distance_list = list.range(0, list.length(other))
      do_distance(one, other, distance_list, 1)
    }
  }
}

fn do_distance(
  one: List(String),
  other: List(String),
  distance_list: List(Int),
  step: Int,
) -> Int {
  case one {
    [] -> result.unwrap(list.last(distance_list), -1)
    [first, ..rest] -> {
      let distance_list =
        update_distance_list(other, distance_list, first, step, [step])
      do_distance(rest, other, distance_list, step + 1)
    }
  }
}

fn update_distance_list(
  other: List(String),
  distance_list: List(Int),
  grapheme: String,
  last_distance: Int,
  acc: List(Int),
) -> List(Int) {
  case other {
    [] -> list.reverse(acc)
    [first, ..rest] ->
      case distance_list {
        [] -> panic
        [first_dist, ..rest_dist] -> {
          let difference = case grapheme == first {
            False -> 1
            True -> 0
          }
          let min = case rest_dist {
            [second_dist, ..] ->
              int.min(first_dist + difference, last_distance + 1)
              |> int.min(second_dist + 1)
            _ -> int.min(first_dist + difference, last_distance + 1)
          }
          update_distance_list(rest, rest_dist, grapheme, min, [min, ..acc])
        }
      }
  }
}

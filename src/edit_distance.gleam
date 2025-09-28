import gleam/int
import gleam/list
import gleam/string

/// Compute the edit distance between two strings using the
/// [Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance).
/// The Levenshtein distance between two strings is the number of edits that
/// will get you from one string to the other; the allowed edits are:
/// - insertion: adding a new character to one of the two strings
/// - deletion: removing a character from one of the two strings
/// - replacemente: replace a character with a new one in one of the two strings
///
/// ## Examples
///
/// ```gleam
/// assert 2 == levenshtein("gleam", "beam")
/// assert 1 == levenshtein("cat", "cap")
/// ```
///
pub fn levenshtein(one: String, other: String) -> Int {
  case one, other {
    _, _ if one == other -> 0
    "", string | string, "" -> string.length(string)
    one, other -> {
      let one = string.to_graphemes(one)
      let other = string.to_graphemes(other)

      // We start with a list with `[0, 1, 2, ...]` becase that's the edit
      // distance from the empty prefix of the first string (our starting point)
      // and the distance with any prefix of the second string.
      let distance_list = list.range(0, list.length(other))
      levenshtein_loop(one, other, distance_list, 0)
    }
  }
}

fn levenshtein_loop(
  one: List(String),
  other: List(String),
  // The list of distances between the first string's prefix (sized
  // `prefix-size`) and all prefixes of the second string.
  // So we know that once the first string is fully consumed the last item of
  // this list is going to be the distance between the original string and the
  // other one; which is the result we wanted!
  distances: List(Int),
  // The size of the pefix of the first string we've consumed so far and for
  // which we're computing the actual distance.
  prefix_size: Int,
) -> Int {
  case one {
    [] -> {
      let assert Ok(distance) = list.last(distances)
        as "distance list will always have at least one item"
      distance
    }

    [first, ..rest] -> {
      // There's an additional character in the string so now we want to update
      // the distance with the new prefix considering this character as well.
      // The prefix size is thus increased by one.
      let prefix_size = prefix_size + 1

      // The first distance is always the distance with the empty prefix of the
      // `other` string. So that is trivially the size of the prefix (we need
      // that many insertions to get from an empty string to a prefix with that
      // many graphemes).
      let new_distances = [prefix_size]
      let distance_list =
        update_distances(first, other, distances, prefix_size, new_distances)

      levenshtein_loop(rest, other, distance_list, prefix_size)
    }
  }
}

fn update_distances(
  grapheme: String,
  other: List(String),
  previous_distances: List(Int),
  last_distance: Int,
  new_distances: List(Int),
) -> List(Int) {
  case other, previous_distances {
    [], _ | _, [] | _, [_] -> list.reverse(new_distances)

    // Here we get the distance we computed previously that is the distance
    // between the shorter prefix of the first string (the one that is not using
    // the `grapheme` we've found) and the shorter prefix of the second string
    // (the one that is not using the `first` grapheme we're matching on here).
    //
    // Let's have a look at an example: say we're comparing "wibble" and "woo"
    // and we've already computed the distances between "wi" and "woo" and
    //
    //              •   w  wo  woo
    //   •       [  0,  1,  2,  3  ]
    //   w       [  1,  0,  1,  2  ]
    //   wi      [   ,   ,   ,     ]
    //   wib     [   ,   ,   ,     ]
    //
    [first, ..other], [previous_distance, ..rest] -> {
      let assert [second_distance, ..] = rest
      let insertion_distance = last_distance + 1
      let deletion_distance = second_distance + 1
      let substitution_distance = case grapheme == first {
        False -> previous_distance + 1
        True -> previous_distance
      }

      let new_distance =
        substitution_distance
        |> int.min(insertion_distance)
        |> int.min(deletion_distance)

      let new_distances = [new_distance, ..new_distances]
      update_distances(grapheme, other, rest, new_distance, new_distances)
    }
  }
}

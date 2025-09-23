import blah/lorem
import edit_distance
import gleam/string
import gleeunit

pub fn main() {
  gleeunit.main()
}

const tries = 1000

fn repeat(times n: Int, action fun: fn() -> a) -> Nil {
  case n {
    _ if n <= 0 -> Nil
    _ -> {
      fun()
      repeat(n - 1, fun)
    }
  }
}

pub fn distance_between_equal_strings_test() -> Nil {
  use <- repeat(tries)
  let string = lorem.word()
  assert 0 == edit_distance.levenshtein(string, string)
}

pub fn distance_with_empty_string_test() -> Nil {
  use <- repeat(tries)
  let string = lorem.word()
  let length = string.length(string)

  assert length == edit_distance.levenshtein(string, "")
  assert length == edit_distance.levenshtein("", string)
}

pub fn distance_is_commutative_test() -> Nil {
  use <- repeat(tries)
  let one = lorem.word()
  let other = lorem.word()
  assert edit_distance.levenshtein(one, other)
    == edit_distance.levenshtein(other, one)
}

pub fn known_distances_test() -> Nil {
  assert 1 == edit_distance.levenshtein("kitten", "sitten")
  assert 1 == edit_distance.levenshtein("sitten", "sittin")
  assert 1 == edit_distance.levenshtein("sittin", "sitting")
  assert 1 == edit_distance.levenshtein("sitting", "sittings")
  assert 3 == edit_distance.levenshtein("kitten", "sitting")
  assert 2 == edit_distance.levenshtein("flaw", "lawn")
  assert 6 == edit_distance.levenshtein("giacomo", "tommaso")
  assert 2 == edit_distance.levenshtein("gleam", "beam")
  assert 2 == edit_distance.levenshtein("this", "that")
}

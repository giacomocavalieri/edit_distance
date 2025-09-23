import blah/lorem
import edit_distance/levenshtein
import gleam/string

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
  assert 0 == levenshtein.distance(string, string)
}

pub fn distance_with_empty_string_test() -> Nil {
  use <- repeat(tries)
  let string = lorem.word()
  let length = string.length(string)

  assert length == levenshtein.distance(string, "")
  assert length == levenshtein.distance("", string)
}

pub fn distance_is_commutative_test() -> Nil {
  use <- repeat(tries)
  let one = lorem.word()
  let other = lorem.word()
  assert levenshtein.distance(one, other) == levenshtein.distance(other, one)
}

pub fn known_distances_test() -> Nil {
  assert 1 == levenshtein.distance("kitten", "sitten")
  assert 1 == levenshtein.distance("sitten", "sittin")
  assert 1 == levenshtein.distance("sittin", "sitting")
  assert 1 == levenshtein.distance("sitting", "sittings")
  assert 3 == levenshtein.distance("kitten", "sitting")
  assert 2 == levenshtein.distance("flaw", "lawn")
  assert 6 == levenshtein.distance("giacomo", "tommaso")
  assert 2 == levenshtein.distance("gleam", "beam")
  assert 2 == levenshtein.distance("this", "that")
}

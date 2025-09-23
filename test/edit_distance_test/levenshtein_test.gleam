import blah/lorem
import edit_distance/levenshtein
import gleam/string
import gleeunit/should

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
  levenshtein.distance(string, string)
  |> should.equal(0)
}

pub fn distance_with_empty_string_test() -> Nil {
  use <- repeat(tries)
  let string = lorem.word()
  let length = string.length(string)

  levenshtein.distance(string, "")
  |> should.equal(length)

  levenshtein.distance("", string)
  |> should.equal(length)
}

pub fn distance_is_commutative_test() -> Nil {
  use <- repeat(tries)
  let one = lorem.word()
  let other = lorem.word()
  levenshtein.distance(one, other)
  |> should.equal(levenshtein.distance(other, one))
}

pub fn known_distances_test() -> Nil {
  levenshtein.distance("kitten", "sitten")
  |> should.equal(1)

  levenshtein.distance("sitten", "sittin")
  |> should.equal(1)

  levenshtein.distance("sittin", "sitting")
  |> should.equal(1)

  levenshtein.distance("sitting", "sittings")
  |> should.equal(1)

  levenshtein.distance("kitten", "sitting")
  |> should.equal(3)

  levenshtein.distance("flaw", "lawn")
  |> should.equal(2)

  levenshtein.distance("giacomo", "tommaso")
  |> should.equal(6)

  levenshtein.distance("gleam", "beam")
  |> should.equal(2)

  levenshtein.distance("this", "that")
  |> should.equal(2)
}

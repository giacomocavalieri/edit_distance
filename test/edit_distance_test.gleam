import edit_distance
import gleam/int
import gleam/string
import gleeunit
import prng/random

pub fn main() {
  gleeunit.main()
}

pub fn distance_between_equal_strings_test() -> Nil {
  use string <- prop(random.string())
  assert 0 == edit_distance.levenshtein(string, string)
}

pub fn distance_with_empty_string_test() -> Nil {
  use string <- prop(random.string())
  let length = string.length(string)

  assert length == edit_distance.levenshtein(string, "")
  assert length == edit_distance.levenshtein("", string)
}

pub fn distance_is_commutative_test() -> Nil {
  use #(one, other) <- prop({
    use one <- random.then(random.string())
    use other <- random.then(random.string())
    random.constant(#(one, other))
  })

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
  assert 1 == edit_distance.levenshtein("a", "b")
  assert 1 == edit_distance.levenshtein("a", "ab")
  assert 1 == edit_distance.levenshtein("ab", "a")
  assert 2 == edit_distance.levenshtein("a", "abc")
  assert 2 == edit_distance.levenshtein("abc", "a")
  assert 0 == edit_distance.levenshtein("a", "a")
}

// --- HELPER FUNCTIONS --------------------------------------------------------

const tries = 3000

fn prop(generator: random.Generator(a), run: fn(a) -> b) -> Nil {
  let seed = random.new_seed(int.random(100_000))
  prop_loop(tries, generator, seed, run)
}

fn prop_loop(
  remaining: Int,
  generator: random.Generator(a),
  seed,
  run: fn(a) -> b,
) -> Nil {
  case remaining {
    0 -> Nil
    _ -> {
      let #(value, seed) = random.step(generator, seed)
      run(value)
      prop_loop(remaining - 1, generator, seed, run)
    }
  }
}

import edit_distance/osa
import gleeunit/should

pub fn osa_test() {
  osa.distance("", "hello")
  |> should.equal(5)

  osa.distance("hello", "")
  |> should.equal(5)

  // Test symmetry
  osa.distance("a", "bbb")
  |> should.equal(3)
  osa.distance("bbb", "a")
  |> should.equal(3)

  osa.distance("hello", "hello")
  |> should.equal(0)

  // Test distinction between uppercase and lowercase letters
  osa.distance("hello", "HELLO")
  |> should.equal(5)

  osa.distance("CA", "ABC")
  |> should.equal(3)

  // Test both strings are empty
  osa.distance("", "")
  |> should.equal(0)

  // Test strings with only one character
  osa.distance("a", "a")
  |> should.equal(0)

  osa.distance("a", "b")
  |> should.equal(1)

  // Test one character, one empty string
  osa.distance("a", "")
  |> should.equal(1)

  osa.distance("", "b")
  |> should.equal(1)

  // Test repeating characters
  osa.distance("aaa", "aaaa")
  |> should.equal(1)

  osa.distance("aaaa", "aaa")
  |> should.equal(1)

  // Test strings with spaces
  osa.distance("hello world", "hello_world")
  |> should.equal(1)

  osa.distance(" a ", "a")
  |> should.equal(2)

  // Test strings with special characters
  osa.distance("!@#", "!@")
  |> should.equal(1)

  osa.distance("!@#", "#@!")
  |> should.equal(2)

  // Test very long strings with minimal differences
  osa.distance("aaaaaaaaaaaaaaaaaaaaa", "aaaaaaaaaaaaaaaaaaaaa")
  |> should.equal(0)

  osa.distance("aaaaaaaaaaaaaaaaaaaaa", "aaaaaaaaaaaaaaaaaaaab")
  |> should.equal(1)

  // Test transpositions
  osa.distance("abc", "acb")
  |> should.equal(1)

  osa.distance("abcdef", "badcfe")
  |> should.equal(3)

  osa.distance("abcdef", "abcfed")
  |> should.equal(2)
}

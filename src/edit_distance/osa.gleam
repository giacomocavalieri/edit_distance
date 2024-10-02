import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string

/// Compute the edit distance between two strings using the Restricted Damerau–Levenshtein, also
/// called the [Optimal String Alignment (OSA) distance](https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance#Optimal_string_alignment_distance).
///  
/// The OSA distance counts operations: Insertions, deletions, substitutions, and limited 
/// transpositions (only adjacent transpositions are allowed).
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
/// ```gleam
/// > distance("wibble", "wibbel")
/// 2
/// ```
/// 
pub fn distance(one: String, other: String) -> Int {
  case one, other {
    // Case: Both strings are empty, so the distance is 0
    "", "" -> 0

    // Case: One string is empty, so the distance is the length of the other. That is, equal to the
    // cost of inserting all characters of the 'other' string and vice versa
    "", _ -> string.length(other)
    _, "" -> string.length(one)

    // Case: Strings are identical, so the distance is 0
    one, other if one == other -> 0

    // General case: Compute the Restricted Damerau-Levenshtein distance recursively
    _, _ -> calculate_distance(one, other)
  }
}

fn calculate_distance(one: String, other: String) -> Int {
  let m = string.length(one)
  let n = string.length(other)

  // Convert both strings to dictionaries for key-value (index-character) access
  // Indexing starts from 0. The indices are:
  // - 0 to m - 1 for 'one' 
  // - 0 to n - 1 for 'other'
  let one_dict = string_to_dict(one)
  let other_dict = string_to_dict(other)

  // Initialize a dictionary, representing a (distance) matrix, to store distance calculations
  // Each key is a tuple (i, j) where i and j represent the lengths of substrings
  // Each corresponding value represents the minimum cost to transform one substring into the
  // other, using a set of allowed operations
  let distance_dict = dict.new()

  // Compute the distances between substrings
  let distance_dict =
    compute_distances(one_dict, other_dict, distance_dict, m, n)

  // Retrieve the final distance between the full strings
  let assert Ok(result) = dict.get(distance_dict, #(m, n))
  result
}

// A function that converts a string into a dictionary of key-value (index-character) pairs
fn string_to_dict(str: String) -> Dict(Int, String) {
  // Split the string into its graphemes
  let string_graphemes = string.to_graphemes(str)

  // Create an index-character dictionary  
  use acc, character, index <- list.index_fold(string_graphemes, dict.new())
  dict.insert(acc, index, character)
}

// A function that gets the minimum of three values (used for the recursive case)
fn min_three(v1: Int, v2: Int, v3: Int) -> Int {
  int.min(v1, int.min(v2, v3))
}

// A function that checks if two characters match and returns the appropriate cost
fn match_cost(
  one: Dict(Int, String),
  i: Int,
  other: Dict(Int, String),
  j: Int,
) -> Int {
  // Return 1 if characters at positions i and j do not match, otherwise returns 0
  case dict.get(one, i), dict.get(other, j) {
    Ok(c0), Ok(c1) if c0 != c1 -> 1
    _, _ -> 0
  }
}

// A function that calculates the edit distance taking into account edit operations: 
// - insertion
// - deletion
// - substitution
// - limited transposition
fn compute_cost(
  one: Dict(Int, String),
  other: Dict(Int, String),
  d: Dict(#(Int, Int), Int),
  i: Int,
  j: Int,
) -> Int {
  let cost = match_cost(one, i - 1, other, j - 1)

  // Calculate insertion cost
  let assert Ok(d_ij1) = dict.get(d, #(i, j - 1))

  // Calculate deletion cost
  let assert Ok(d_i1j) = dict.get(d, #(i - 1, j))

  // Calculate substitution cost
  let assert Ok(d_i1j1) = dict.get(d, #(i - 1, j - 1))

  // Find the minimum cost between insertion, deletion, and substitution
  let min_cost = min_three(d_i1j + 1, d_ij1 + 1, d_i1j1 + cost)

  // Finally, take into account the cost of a transposition
  let updated_cost = case i > 1 && j > 1 {
    True -> {
      case check_transposition(one, i - 1, other, j - 1) {
        True -> {
          let assert Ok(d_i2j2) = dict.get(d, #(i - 2, j - 2))
          int.min(min_cost, d_i2j2 + 1)
        }
        False -> min_cost
      }
    }
    False -> min_cost
  }
  updated_cost
}

// Check if a transposition is valid by comparing adjacent characters in both strings
fn check_transposition(
  one: Dict(Int, String),
  i: Int,
  other: Dict(Int, String),
  j: Int,
) -> Bool {
  let one_i = dict.get(one, i)
  let other_j = dict.get(other, j)
  let one_i1 = dict.get(one, i - 1)
  let other_j1 = dict.get(other, j - 1)

  // Check if transposing adjacent characters results in a match
  case one_i, other_j1, one_i1, other_j {
    Ok(c0), Ok(c1), Ok(c2), Ok(c3) if c0 == c1 && c2 == c3 -> True
    _, _, _, _ -> False
  }
}

fn fold_range(start: Int, end: Int, acc: a, fun: fn(a, Int) -> a) -> a {
  case start > end {
    True -> acc
    False -> {
      let updated_acc = fun(acc, start)
      fold_range(start + 1, end, updated_acc, fun)
    }
  }
}

// Compute the edit distance by filling the distance matrix with the minimum costs
fn compute_distances(
  one: Dict(Int, String),
  other: Dict(Int, String),
  d: Dict(#(Int, Int), Int),
  m: Int,
  n: Int,
) -> Dict(#(Int, Int), Int) {
  // Initialize base cases, to avoid continuously checking these later on
  // Fixing i = 0 or j = 0, set the cost of transforming one string into the other
  let d = {
    use acc, i <- fold_range(0, m, d)
    dict.insert(acc, #(i, 0), i)
  }
  let d = {
    use acc, j <- fold_range(1, n, d)
    dict.insert(acc, #(0, j), j)
  }

  // Iterate over the matrix to calculate the minimum costs for all substrings
  use acc, i <- fold_range(1, m, d)
  use acc, j <- fold_range(1, n, acc)

  // Calculate the cost for this position (i, j)
  let cost = compute_cost(one, other, acc, i, j)

  // Update the distance dictionary with the calculated cost
  dict.insert(acc, #(i, j), cost)
}

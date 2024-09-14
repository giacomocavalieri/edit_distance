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

  // Build a list of tuples where each tuple contains an index and the corresponding character
  let string_dict =
    list.index_fold(string_graphemes, [], fn(acc, item, i) {
      [#(i, item), ..acc]
    })

  // Convert the list of index-character tuples into a dictionary
  dict.from_list(string_dict)
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
  // Calculate deletion cost
  let d_i1j = get_cost(d, i - 1, j) + 1
  // Calculate insertion cost
  let d_ij1 = get_cost(d, i, j - 1) + 1
  // Calculate substitution cost
  let d_i1j1 = get_cost(d, i - 1, j - 1) + cost

  // Find the minimum cost between insertion, deletion, and substitution
  let min_cost = min_three(d_i1j, d_ij1, d_i1j1)

  // Finally, take into account the cost of a transposition
  let updated_cost = case i > 1 && j > 1 {
    True -> {
      case check_transposition(one, i - 1, other, j - 1) {
        True -> int.min(min_cost, get_cost(d, i - 2, j - 2) + 1)
        False -> min_cost
      }
    }
    False -> min_cost
  }
  updated_cost
}

// A function that retrieves an edit cost from the dictionary representing a distance matrix.
// The function retrieves the cost using the tuple (row_index, column_index) as the key. 
// The value corresponds to the distance calculated between the substrings: 
// - 'one' (from position 0 to row_index)
// - 'other' (from position 0 to column_index) 
// Since the matrix (and thus the dictionary) is processed iteratively (row-wise and column-wise), 
// the value at index (row_index, column_index), where row_index < i and column_index < j, 
// will already be present in the matrix by the time we calculate the value for entry (i, j). We 
// can thus access this entry with confidence
fn get_cost(d: Dict(#(Int, Int), Int), row: Int, column: Int) -> Int {
  let assert Ok(cost) = dict.get(d, #(row, column))
  cost
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

// Compute the edit distance by filling the distance matrix with the minimum costs
fn compute_distances(
  one: Dict(Int, String),
  other: Dict(Int, String),
  d: Dict(#(Int, Int), Int),
  m: Int,
  n: Int,
) -> Dict(#(Int, Int), Int) {
  // Initialize base cases, to avoid continuously checking these later on
  // Fixing i = 0 or j = 0, set the value of transforming one string into the other
  let d = {
    use acc_d, i <- list.fold(list.range(0, m), d)
    dict.insert(acc_d, #(i, 0), i)
  }
  let d = {
    use acc_d, j <- list.fold(list.range(0, n), d)
    dict.insert(acc_d, #(0, j), j)
  }

  // Iterate over the matrix to calculate the minimum costs for all substrings
  use acc_d, i <- list.fold(list.range(1, m), d)
  use inner_d, j <- list.fold(list.range(1, n), acc_d)
  // Calculate the cost for this position (i, j)
  let cost = compute_cost(one, other, inner_d, i, j)
  // Update the distance dictionary with the calculated cost
  dict.insert(inner_d, #(i, j), cost)
}

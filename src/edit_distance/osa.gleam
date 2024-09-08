import gleam/dict
import gleam/int
import gleam/list
import gleam/result
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
    // Base case: Both strings are empty, so the distance is 0
    "", "" -> 0

    // Case: One string is empty, distance is the length of the other (insertion cost)
    "", _ -> string.length(other)
    _, "" -> string.length(one)

    // Case: Strings are identical, no cost
    one, other if one == other -> 0

    // General case: Compute the Restricted Damerau-Levenshtein distance recursively
    _, _ -> calculate_distance(one, other)
  }
}

fn calculate_distance(one: String, other: String) -> Int {
  let n = string.length(one)
  let m = string.length(other)

  // Convert both strings to dictionaries for key-value access
  let one_dict = string_to_dict(one)
  let other_dict = string_to_dict(other)

  // Initialize a matrix to store distance calculations
  let distance_dict = init_dict(n, m)

  // Compute the final distances between substrings
  let distance_dict =
    compute_distances(one_dict, other_dict, distance_dict, n, m)

  // Return the final distance between the full strings
  let assert Ok(result) = dict.get(distance_dict, #(n, m))
  result
}

fn string_to_dict(str: String) -> dict.Dict(Int, String) {
  // Convert the string to a list of strings and build a dictionary
  let string_graphemes = string.to_graphemes(str)
  let string_dict =
    list.index_fold(string_graphemes, [], fn(acc, item, i) {
      [#(i, item), ..acc]
    })

  // Create a dictionary where keys are indices and values are strings
  dict.from_list(string_dict)
}

fn init_dict(n: Int, m: Int) -> dict.Dict(#(Int, Int), Int) {
  let matrix =
    list.fold(list.range(0, n), [], fn(outer_acc, i) {
      list.fold(list.range(0, m), outer_acc, fn(inner_acc, j) {
        // Base cases: Filling the first row and column with distances
        // corresponding to the insertion and deletion operations
        case i == 0, j == 0 {
          True, _ -> {
            [#(#(i, j), j), ..inner_acc]
          }
          _, True -> {
            [#(#(i, j), i), ..inner_acc]
          }
          // Initialize the rest of the matrix with 0.0
          False, False -> [#(#(i, j), 0), ..inner_acc]
        }
      })
    })

  // Convert the initialized matrix to a dictionary
  dict.from_list(matrix)
}

// Helper function to get the minimum of three values (used for the recursive case)
fn min_three(a: Int, b: Int, c: Int) -> Int {
  int.min(a, int.min(b, c))
}

// Calculate the basic edit distance using insertion, deletion, and substitution costs
fn compute_cost(
  one: dict.Dict(Int, String),
  other: dict.Dict(Int, String),
  d: dict.Dict(#(Int, Int), Int),
  i: Int,
  j: Int,
) -> Int {
  // Cost is 1 if characters do not match, 0 if they do
  let cost = case dict.get(one, i - 1), dict.get(other, j - 1) {
    Ok(c0), Ok(c1) if c0 != c1 -> 1
    _, _ -> 0
  }

  // Calculate the minimum distance by considering deletion, insertion, and substitution
  let d_ij_1 = dict.get(d, #(i - 1, j - 1)) |> result.unwrap(0)
  let d_i_j1 = dict.get(d, #(i, j - 1)) |> result.unwrap(0)
  let d_i1_j = dict.get(d, #(i - 1, j)) |> result.unwrap(0)

  // Return the minimum of the three options (deletion, insertion, substitution)
  min_three(d_ij_1 + cost, d_i_j1 + 1, d_i1_j + 1)
}

// Handle transpositions: if two adjacent characters are swapped
fn check_transposition(
  one: dict.Dict(Int, String),
  other: dict.Dict(Int, String),
  d: dict.Dict(#(Int, Int), Int),
  i: Int,
  j: Int,
) -> Int {
  case i <= 1 || j <= 1 {
    // Return early if transposition is not possible (i or j are too small)
    True -> dict.get(d, #(i, j)) |> result.unwrap(0)

    // Otherwise, check for transpositions
    False -> {
      let one_i1 = dict.get(one, i - 1)
      let other_j1 = dict.get(other, j - 1)
      let one_i2 = dict.get(one, i - 2)
      let other_j2 = dict.get(other, j - 2)
      let d_prev = dict.get(d, #(i - 2, j - 2))
      let d_current = dict.get(d, #(i, j))

      // Case: If a transposition is found, compare the distance with the normal edit distance
      case one_i1, other_j2, one_i2, other_j1, d_prev, d_current {
        Ok(c0), Ok(c1), Ok(c2), Ok(c3), Ok(prev_distance), Ok(current_distance)
          if c0 == c1 && c2 == c3
        -> {
          let transposition_cost = prev_distance + 1
          int.min(current_distance, transposition_cost)
        }
        Ok(_), Ok(_), Ok(_), Ok(_), _, Ok(current_distance) -> current_distance
        _, _, _, _, _, _ -> dict.get(d, #(i, j)) |> result.unwrap(0)
      }
    }
  }
}

// Compute the distance by combining all costs: insertion, deletion, substitution, and transposition
fn compute_distances(
  one: dict.Dict(Int, String),
  other: dict.Dict(Int, String),
  d: dict.Dict(#(Int, Int), Int),
  n: Int,
  m: Int,
) -> dict.Dict(#(Int, Int), Int) {
  // Iterate over the matrix, updating distances
  list.fold(list.range(1, n), d, fn(acc_d, i) {
    list.fold(list.range(1, m), acc_d, fn(inner_d, j) {
      // Calculate basic cost (insertion, deletion, substitution)
      let cost = compute_cost(one, other, inner_d, i, j)

      // Update the distance dictionary with the computed cost
      let updated_d = dict.insert(inner_d, #(i, j), cost)

      // Check for transpositions to update the distances
      let final_d =
        dict.insert(
          updated_d,
          #(i, j),
          check_transposition(one, other, updated_d, i, j),
        )
      final_d
    })
  })
}

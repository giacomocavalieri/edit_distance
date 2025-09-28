// import edit_distance
// import gleam/string
// import glychee/benchmark

// pub fn main() {
//   benchmark.run(
//     [
//       fun("lev", fn(pair: #(_, _)) { edit_distance.levenshtein(pair.0, pair.1) }),
//     ],
//     [
//       data("short_and_long", #("lustre", string.repeat("b", 100))),
//       data("long_and_short", #(string.repeat("b", 100), "lustre")),
//       data("long_and_long", #(string.repeat("b", 100), string.repeat("a", 100))),

//       // 760.04 K
//       data("short_and_short", #("lustre", "luster")),
//     ],
//   )
// }

// fn fun(label: String, do: fn(a) -> b) -> benchmark.Function(a, b) {
//   benchmark.Function(label, fn(a) { fn() { do(a) } })
// }

// fn data(label: String, data: a) {
//   benchmark.Data(label, data)
// }

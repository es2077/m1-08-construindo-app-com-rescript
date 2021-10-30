let s = React.string
let map = (items, fn) =>
  items->Js.Array2.mapi((item, index) => fn(item, index->Js.Int.toString))->React.array

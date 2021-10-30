open Render
open Ancestor.Default

module Styles = {
  open Emotion

  let {toString: colorToString} = module(Theme.Colors)

  let button = (~disabled) =>
    css({
      "outline": "none",
      "border": "none",
      "color": Theme.Colors.white->colorToString,
      "backgroundColor": Theme.Colors.primary->colorToString,
      "minWidth": "10.5rem",
      "borderRadius": "6px",
      "height": "3.8rem",
      "fontSize": "1.6rem",
      "lineHeight": "2.1rem",
      "letterSpacing": "-0.035em",
      "cursor": disabled ? "not-allowed" : "pointer",
      "transition": "300ms",
      "opacity": disabled ? "0.5" : "1",
      "&:hover": {
        "backgroundColor": Theme.Colors.primaryDark->colorToString,
      },
    })
}

@react.component
let make = (~children, ~onClick=?, ~disabled=false, ~loading=false) => {
  <button disabled ?onClick className={Styles.button(~disabled)}>
    {switch loading {
    | false => children->s
    | true => <Base tag=#img width=[xs(2.4->#rem)] src=Assets.spinner />
    }}
  </button>
}

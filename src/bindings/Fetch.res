type response

@send external json: response => Js.Promise.t<Js.Json.t> = "json"
@val external fetch: (string, {..}) => Js.Promise.t<response> = "fetch"

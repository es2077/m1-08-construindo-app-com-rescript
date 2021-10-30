// format(new Date(), "'Today is a' eeee")

@module("date-fns") external format: (Js.Date.t, string) => string = "format"

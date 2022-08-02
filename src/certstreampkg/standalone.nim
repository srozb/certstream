import yaml/serialization, streams

type 
  Match* = object
    fuzzy* {.defaultVal: @[""].}: seq[string]
    suffix* {.defaultVal: @[""].}: seq[string]
  Log* = object
    stdout* {.defaultVal: false.}: bool
    matched* {.defaultVal: "".}: string
  Config* = object
    match*: Match
    log*: Log

proc parseConfig*(fn: string): Config =
  var s = newFileStream(fn)
  load(s, result)
  s.close()
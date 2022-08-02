import asyncdispatch
import std/logging
import strformat
import strutils
import ws
import fuzzy
import certstreampkg/parser
import certstreampkg/standalone

const CSURL = "wss://certstream.calidog.io"

var csSock: WebSocket

proc setup(wsock: var WebSocket) =
  wsock = waitFor newWebSocket(CSURL)
  debug "Websocket connection established"
  wsock.setupPings(15)  # may cause SEGV on reconnect

proc getMsg(): Future[string] {.async.} = 
  ## Gets ws message, handling reconnections
  try:
    result = await csSock.receiveStrPacket
  except WebSocketError:
    debug "Disconnected"
    csSock.setup

proc getRec(): Record =
  ## Returns parsed message, ignores pings
  var msg: string
  while msg.len == 0: msg = waitFor getMsg()
  msg.parseMsg

proc subscribe() =
  ## Subscribe and print raw certstream messages to stdout.
  ## Output data can be piped to jq or processed further as json.
  while true: echo waitFor getMsg()

proc fuzzyMatch(domains: seq[string], keywords: seq[string], threshold = 0.8): bool =
  ## Fuzzy match domains with keywords. Immediately returns true if matched.
  for d in domains:
    for k in keywords:
      let match = fuzzyMatchSmart(d, k)
      if match > threshold:
        debug fmt"{d}: matches {k} ({match})"
        return true

proc fuzzyHunt(keywords: seq[string]) =
  ## Match certstream with given keywords using lavenstein distance.
  if keywords.len == 0:
    error "need at least one keyword to match with"
    return
  while true: 
    let rec = getRec()
    if fuzzyMatch(rec.data.leaf_cert.all_domains, keywords): echo $rec.data

proc suffixMatch(domains: seq[string], keywords: seq[string]): bool =
  ## Returns true as soon as a domain ends with a keyword.
  for d in domains:
    for k in keywords:
      if d.endsWith(k): return true

proc monitor(keywords: seq[string]) =
  ## Match certstream with given domain suffix(es).
  if keywords.len == 0:
    fatal "need at least one keyword to match with"
    return
  while true: 
    let rec = getRec()
    if suffixMatch(rec.data.leaf_cert.all_domains, keywords): 
      echo $rec.data

proc reportFinding(rec: Record, matchType: string, matchedLog: Logger) = 
  notice fmt"{matchType}Match: {rec.data.leafCert}"
  matchedLog.log(lvlInfo, $rec.data)

proc daemon(config = "config.yml") = 
  ## Run daemon based on provided configuration file. (Consult config.yml.dist)
  var 
    c = parseConfig(config)
    consoleLog = newConsoleLogger()
    matchedLog: RollingFileLogger
  if c.log.stdout: addHandler(consoleLog)
  if c.log.matched.len > 0:
    matchedLog = newRollingFileLogger(
      c.log.matched, 
      fmtStr = "",
      mode = fmAppend,
      maxLines=10000
    )
  info "Starting certstream daemon"
  while true: 
    let rec = getRec()
    if c.match.fuzzy.len > 0:
      if fuzzyMatch(rec.data.leaf_cert.all_domains, c.match.fuzzy, 0.8):  # TODO: config threshold
        rec.reportFinding("fuzzy", matchedLog)
    if c.match.suffix.len > 0:
      if suffixMatch(rec.data.leaf_cert.all_domains, c.match.suffix):
        rec.reportFinding("suffix", matchedLog)

when isMainModule:
  import cligen
  csSock.setup
  dispatchMulti(
    [subscribe],
    [fuzzyHunt],
    [monitor],
    [daemon]
  )
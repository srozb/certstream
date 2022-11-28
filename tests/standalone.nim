{.used.}

import unittest
import certstreampkg/standalone

test "parse sample config":
  let cfg = parseConfig("config.yml.dist")
  check cfg.match.fuzzy == @["password", "authentication"]
  check cfg.match.suffix == @[".youtube.com", ".gmail.com"]
  check cfg.log.stdout
  check cfg.log.matched == "output/output.json"
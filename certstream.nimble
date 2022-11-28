# Package

version       = "0.1.2"
author        = "srozb"
description   = "Unofficial certstream client"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["certstream"]
binDir        = "release"


# Dependencies

requires "nim >= 1.6.4, cligen >= 1.5.10, ws >= 0.4.0, jsony >= 1.1.0, fuzzy >= 0.1.0, yaml >= 1.0.0"

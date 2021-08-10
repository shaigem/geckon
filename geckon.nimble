# Package

version       = "0.1.0"
author        = "Ronnie Tran"
description   = "Simple framework for creating Gecko codes in Nim"
license       = "MIT"
srcDir        = "src"
bin = @["geckon"]

# Dependencies

requires "nim >= 1.5.1"

task melee, "Create melee gecko codes":
  exec "nim r melee/buildmelee.nim"
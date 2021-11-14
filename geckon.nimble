# Package

version       = "1.0.0"
author        = "Ronnie Tran"
description   = "Simple framework for creating Gecko codes in Nim"
license       = "MIT"
srcDir        = "src"
bin = @["geckon"]

# Dependencies

requires "nim >= 1.6.0"

task test, "Run tests":
  exec "nimble c -y -r tests/tppcmacro.nim"
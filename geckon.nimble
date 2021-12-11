# Package

version       = "0.1.0"
author        = "Ronnie Tran"
description   = "Simple framework for creating Gecko codes in Nim"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 1.6.0"

task test, "Run tests":
  exec "nimble c -y -r tests/tppcmacro.nim"
  exec "nimble c -y -r tests/tcodescript.nim"
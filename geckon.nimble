# Package

version       = "0.1.0"
author        = "Ronnie Tran"
description   = "Simple framework for creating Gecko codes in Nim"
license       = "MIT"
srcDir        = "src"
bin = @["geckon"]

# Dependencies

requires "nim >= 1.5.1"


task codes, "Create Gecko codes from the 'codes' folder":
  exec "nim r codes/build.nim"
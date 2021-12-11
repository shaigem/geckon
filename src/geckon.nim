import geckon / [ppcasm, codescript]
import std/[os, parseOpt, tempFiles, macros]

export ppcasm, codescript

proc generate*(outputPath: string; codeScripts: varargs[GeckoCodeScript]) {.compileTime.} =
    if codeScripts.len == 0:
        return
    let includeStmt = """
.include "punkpc.s"
punkpc ppc

"""
    for s in codeScripts:
        echo outputPath, " ", s.name, " "
        try:
            writeFile(outputPath, includeStmt & s.code)
        except IOError as e:
            raise (ref IOError)(msg: e.msg)

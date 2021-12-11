import geckon / [ppcasm, codescript]
import std/[os, strformat]

export ppcasm, codescript

func generateHeader(codeScript: GeckoCodeScript): string =
    &"""
# generated with geckon
# {codeScript.name}
# authors: {codeScript.authors}
# description: {codeScript.description}
.include "punkpc.s"
punkpc ppc

"""

proc generate*(outputPath: string; codeScripts: varargs[GeckoCodeScript]) =
    if codeScripts.len == 0:
        raise newException(ValueError, "no code scripts specified")
    for s in codeScripts:
        try:
            let dir = splitFile(outputPath).dir
            createDir(dir)
            writeFile(outputPath, generateHeader(s) & s.code)
        except IOError as e:
            raise (ref IOError)(msg: e.msg)

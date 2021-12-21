import geckon / [ppcasm, codescript]
import std/[os, strformat]

export ppcasm, codescript

const PunkpcImport = """.include "punkpc.s"
punkpc ppc
"""

func generateHeader(codeScript: GeckoCodeScript): string =
    &"""
# {codeScript.name}
# authors: {codeScript.authors}
# description: {codeScript.description}
"""

proc generate*(outputPath: string; codeScripts: varargs[GeckoCodeScript]) =
    if codeScripts.len == 0:
        raise newException(ValueError, "no code scripts specified")
    try:
        let dir = splitFile(outputPath).dir
        createDir(dir)
        let f = open(outputPath, fmReadWrite)
        f.write(PunkpcImport)
        for s in codeScripts:
                f.write(generateHeader(s) & s.code & "\n")
        f.close()
    except IOError as e:
        raise (ref IOError)(msg: e.msg)

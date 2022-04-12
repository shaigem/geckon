import std/macros
import ppcasm, assembler
import std/os
import std/tempfiles
import strutils

const 
    DefaultIncludeHeader = """.include "punkpc.s"
punkpc ppc
"""
    AsmExt = ".asm"

type
    GeckoCodeScript* = object
        name*: string
        authors*: seq[string]
        description*: string
        code*: string

macro createCode*(codeName: string; list: untyped): untyped =
    expectKind list, nnkStmtList
    result = newEmptyNode()
    var script = GeckoCodeScript()
    for c in list:
        expectKind c, nnkCall
        let lbl = c[0].strVal
        let b = c[1]
        case lbl          
        of "name":
            expectKind b[0], {nnkStrLit, nnkIdent}
            script.name = b[0].strVal
        of "description":
            expectKind b[0], nnkStrLit
            script.description = b[0].strVal
        of "authors":
            let authors = b[0]
            expectKind authors, nnkBracket
            for author in authors:
                expectKind author, nnkStrLit
                script.authors.add author.strVal
        of "code":
            let codeSectionBody = b
            expectKind codeSectionBody, nnkStmtList
            let sc = newLit script
            let cn = codeName
            result = quote do:
                var scr = `sc`
                var cn = `cn`
                scr.name = cn
                scr.code = ppc: `codeSectionBody`
                scr
        else:
            error "unknown code section label: " & lbl & "\n" & treeRepr(c)

    if result.kind == nnkEmpty:
        error "must have a `code` section defined"

proc getCodeHeader(codeScript: GeckoCodeScript): string =
    &"""
# {codeScript.name}
# authors: {codeScript.authors}
# description: {codeScript.description}
"""

proc asFormattedAsm*(codeScript: GeckoCodeScript): string = DefaultIncludeHeader & getCodeHeader(codeScript) & codeScript.code

proc toGeckoCode*(codeScript: GeckoCodeScript): string =
    let (tempAsmFile, tempAsmFilePath) = createTempFile("gcs_", ".asm")
    tempAsmFile.write codeScript.asFormattedAsm()
    tempAsmFile.close()

    let (tempElfFile, tempElfFilePath) = createTempFile("gcs_", ".elf")
    tempElfFile.close()

    let (output, success) = execAssemble(tempAsmFilePath, tempElfFilePath)
    if not success:
        raise newException(ValueError,
            "Could not assemble your asm code " & output)
    let (objcopyOutput, objcopySuccess) = execObjCopy(tempElfFilePath, tempElfFilePath)
    if not objcopySuccess:
        raise newException(CatchableError,
            "Could not perform objcopy on your asm code " & objcopyOutput)
    let rawCodesFile = open(tempElfFilePath, fmRead)
    var codes = readAll(rawCodesFile)
    if codes.len mod 8 != 0:
        for i in 0..3:
            codes.add 0.char
    for i in countup(0, codes.len - 1, 8):
        result.add codes[i ..< i + 4].toHex() & " " & codes[i + 4 ..< i + 8].toHex() & "\n"
    rawCodesFile.close()
    removeFile(tempAsmFilePath)
    removeFile(tempElfFilePath)

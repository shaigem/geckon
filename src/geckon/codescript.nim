import std/macros
import ppcasm

type
    GeckoCodeScript* = object
        name*: string
        authors*: seq[string]
        description*: string
        code*: string

macro createCode*(codeName: string, list: untyped): untyped =
    expectKind list, nnkStmtList
    result = newEmptyNode()
    var script = GeckoCodeScript(name: codeName.strVal)
    for c in list:
        expectKind c, nnkCall
        let lbl = c[0].strVal
        let b = c[1]
        case lbl
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
            result = quote do:
                var scr = `sc`
                scr.code = ppc: `codeSectionBody`
                scr
        else:
            error "unknown code section label: " & lbl & "\n" & treeRepr(c)

    if result.kind == nnkEmpty:
        error "must have a `code` section defined"

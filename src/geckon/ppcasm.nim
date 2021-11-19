import macros

from strformat import `&`
from strutils import strip

export `&`, strip

type
    Register* {.pure.} = enum
        r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14,
                        r15,
                r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26,
                                r27, r28,
                r29, r30, r31
        f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14,
                        f15,
                f16, f17, f18, f19, f20, f21, f22, f23, f24, f25, f26,
                                f27, f28,
                f29, f30, f31
    Align* = range[0 .. 12]

proc ppcImpl(c, b: NimNode): NimNode =
    result = newStmtList()

    template addToString(a: untyped, newLineSuffix: string{
                        lit} = "\n"): untyped =
        let code = infix(a, "&", newStrLitNode(newLineSuffix))
        let infix = infix(c, "&=", code)
        result.add infix

    case b.kind:
    of nnkCall:
        let name = b[0]
        expectKind name, nnkIdent
        if b.len == 1:
            error("Invalid call with the name of: " & name.strVal, b)
            return
        let isLabel = b[1].kind == nnkStmtList
        addToString(name.toStrLit(), ":\n")
        if isLabel:
            for i in 1 ..< b.len:
                result.add ppcImpl(c, b[i])
    of nnkStmtList:
        for n in b:
            result.add ppcImpl(c, n)
    of nnkCommand:
        let toStrNode = newStrLitNode("")
        let commandIdent = b[0]
        if commandIdent.kind == nnkStrLit:
            toStrNode.strVal = commandIdent.strVal
        else:
            toStrNode.strVal = commandIdent.repr
        for i in 1 ..< b.len:
            let toAppend = toStrNode.strVal & " " & b[i].repr &
                    (if i == b.len - 1:
                        "\n"
                    else:
                        ",")
            toStrNode.strVal = toAppend
        result.add infix(c, "&=", prefix(toStrNode, "&"))
    of nnkBlockStmt:
        addToString(b)
    of nnkIdent:
        addToString(b.toStrLit())
    of nnkPrefix:
        let prefixChar = b[0]
        case prefixChar.strVal:
        of "%":
            addToString(b[1])
        else:
            error "invalid prefix char of " & prefixChar.strVal, b
    else:
        error "Invalid node kind: " & $b.kind & ", line: " & b.repr, b

macro ppc*(x: untyped): untyped =
    let resultingCode = genSym(nskVar, "result")
    result = newStmtList()
    result.add newVarStmt(resultingCode, newStrLitNode(""))
    result.add ppcImpl(resultingCode, x)
    result.add newCall(ident("strip"), resultingCode)

template `%`*(f: untyped): string =
    f

template `bgt-`*(label: untyped): string =
    ppc:
        "bgt-" label

template `blt-`*(label: untyped): string =
    ppc:
        "blt-" label

template `bne-`*(label: untyped): string =
    ppc:
        "bne-" label

template `beq-`*(label: untyped): string =
    ppc:
        "beq-" label

template `bne+`*(label: untyped): string =
    ppc:
        "bne+" label

template `mr.`*(ra, rs: Register): string =
    "mr. " & $ra & ", " & $rs 

template `bge-`*(label: untyped): string =
    ppc:
        "bge-" label

template `bge+`*(label: untyped): string =
    ppc:
        "bge+" label

template `ble-`*(label: untyped): string =
    ppc:
        "ble-" label

proc `rlwinm.`*(ra, rs: Register, sh, mb, me: Natural): string =
    "rlwinm. " & $ra & ", " & $rs & ", " & $sh & ", " & $mb & ", " & $me

proc `.float`*(f: float32): string =
    ".float " & $f

proc `.word`*(f: int): string =
    ".word " & $f

proc `.align`*(n: Align): string =
    ".align " & $n

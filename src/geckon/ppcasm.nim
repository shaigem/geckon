import std/macros

proc ppcImpl(n: NimNode): NimNode
proc toAsmString(n: NimNode): NimNode
proc parseCommand(n: NimNode, seperator: string = ", "): NimNode

proc parsePrefix(n: NimNode): NimNode =
    # TODO feels like lots of stuff could be reused
    expectKind n, nnkPrefix
    expectKind n[0], nnkIdent
#    expectIdent n[0], "%"
    let secondArg = n[1]
    let lastArg = n[^1]
    if n[0].strVal == "%%": # TODO probably merge this with %...
        if secondArg.kind == nnkCall:
            secondArg[0] = prefix(secondArg[0], "$")
            secondArg[1] = toAsmString(newPar(secondArg[1]))
            result = infix(secondArg[0], "&", secondArg[1])
    elif n[0].strVal == "@":
        expectLen n, 2
        expectKind n[1], nnkIdent
        result = newStrLitNode(n[0].strVal & n[1].strVal)
    elif n[0].strVal == "%":
        case secondArg.kind
        of nnkIdent:
            result = prefix(secondArg, "$")
        of nnkCall:
            if lastArg.kind == nnkStmtList:
                secondArg.add lastArg
            result = secondArg
        of nnkPar:
            # TODO should we prefix it with $ or let the programmer manually do it?
            result = prefix(secondArg[0], "$")
        of nnkCommand:
            expectKind secondArg, nnkCommand
            expectLen secondArg, 2
            secondArg[0] = prefix(secondArg[0], "$")
            secondArg[1] = toAsmString(secondArg[1])
            result = infix(infix(secondArg[0], "&", newLit" "), "&", secondArg[1])
        else:
            error "unknown prefix kind: " & $n[1].kind & "\n" & treeRepr(n)

proc parsePar(n: NimNode): NimNode =
    expectKind n, nnkPar
    result = newStmtList()
    let addSym = bindSym"add"
    var output = gensym(nskVar, "output")
    result.add newVarStmt(output, newLit"(")
    for i, c in n:
        result.add newCall(addSym, output, toAsmString(c))
    result.add newCall(addSym, output, newLit")")      
    result.add output

proc toAsmString(n: NimNode): NimNode =
    case n.kind
    of nnkInfix:
        expectLen n, 3
        let op = n[0]
        let ls = n[1]
        let rs = n[2]
        result = newStrLitNode(ls.strVal & op.strVal & " " & rs.strVal)
    of nnkDotExpr:
        expectLen n, 2
        result = newStrLitNode(n[0].strVal & "." & n[1].strVal)
    of nnkIdent:
        result = n.toStrLit
    of nnkFloatLit:
        result = n.toStrLit
    of nnkIntLit, nnkInt64Lit:
        result = newStrLitNode($n.intVal)
    of nnkCall, nnkCommand:
        result = ppcImpl(n)
    of nnkPrefix:
        result = parsePrefix(n)
    of nnkPar:
        result = parsePar(n)
    else:
        error "unknown node kind for parsing to ASM string: " & $n.kind & "\n" & treeRepr(n)

proc parseCommand(n: NimNode, seperator: string = ", "): NimNode =
    expectMinLen n, 1
    result = newStmtList()
    let addSym = bindSym"add"
    var output = gensym(nskVar, "output")
    result.add newVarStmt(output, newLit"")
    let endIndex = n.len - 1
    for i, c in n:
        result.add newCall(addSym, output, toAsmString(c))
        let seperator = newLit(if i == 0: " " elif i == endIndex : "" else: seperator)
        result.add newCall(addSym, output, seperator)
    result.add output

proc parseStmtList(n: NimNode): NimNode =
    expectKind n, nnkStmtList
    expectMinLen n, 1
    result = newStmtList()
    let addSym = bindSym"add"
    var parsedList = gensym(nskVar, "parsed")
    result.add newVarStmt(parsedList, newLit"")
    let endIndex = n.len - 1
    for i, c in n:
        result.add newCall(addSym, parsedList, toAsmString(c))
        if i < endIndex:
            result.add newCall(addSym, parsedList, newLit("\n"))
    result.add parsedList

proc parseBlockStmt(n: NimNode): NimNode =
    expectKind n, nnkBlockStmt
    expectMinLen n, 1
    result = newStmtList()
    let addSym = bindSym"add"
    var parsedList = gensym(nskVar, "parsed")
    result.add newVarStmt(parsedList, newLit"")
    result.add newCall(addSym, parsedList, n)
    result.add parsedList

proc ppcImpl(n: NimNode): NimNode =
    case n.kind
    of nnkCall:
        if n[0].kind == nnkIdent:
            let name = toAsmString(n[0])
            let lastNode = n[^1]
            expectKind lastNode, nnkStmtList
            let parsed = parseStmtList(lastNode)
            result = infix(infix(name, "&", newLit(":\n")), "&", parsed)
        elif n[0].kind == nnkAccQuoted:
            let acc = n[0]
            let newIdentNode = ident(acc[0].strVal & acc[1].strVal) # combine (example: .float)
            n[0] = newIdentNode
            result = parseCommand(n)
        elif n[0].kind == nnkIntLit:
            expectLen n, 2
            expectKind n[1], {nnkIdent, nnkPrefix}
            n[1] = toAsmString(newPar(n[1]))
            result = infix(toAsmString(n[0]), "&", n[1])
    of nnkCommand:
        result = parseCommand(n)
    of nnkBlockStmt:
        result = parseBlockStmt(n)
    of nnkStmtList:
        result = parseStmtList(n)
    of nnkIdent, nnkDotExpr, nnkInfix, nnkPrefix:
        result = toAsmString(n)
    else:
        error "unknown node kind for body: " & $n.kind & "\n" & treeRepr(n)

macro ppc*(n: untyped): string =
    expectKind(n, nnkStmtList)
    let addSym = bindSym"add"
    let res = genSym(nskVar, "result")
    result = newStmtList()
    result.add newVarStmt(res, newStrLitNode"")
    let endIndex = n.len - 1
    for i, c in n:
        let parsedLine = ppcImpl(c)
        let nodeToAdd = if i != endIndex: infix(parsedLine, "&", newStrLitNode("\n")) else: parsedLine
        result.add newCall(addSym, res, nodeToAdd)
    result.add res
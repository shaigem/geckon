import macros, strutils

from strformat import `&`

export `&`

type CodeSectionNodeKind* {.pure.} = enum
        InsertAsmNode = "C2", Write32BitsNode = "04", AuthorsNode, DescriptionNode

type CodeSectionNode* = object
        case kind*: CodeSectionNodeKind
        of InsertAsmNode, Write32BitsNode:
                targetAddress*: string
                code*: string
        of AuthorsNode:
                authors*: seq[string]
        of DescriptionNode:
                description*: string

type CodeNode* = object
        name*: string
        authorsSection*: CodeSectionNode
        descriptionSection*: CodeSectionNode
        sections*: seq[CodeSectionNode]

func toSnakeCase*(codeName: string): string = codeName.toLower().replace(" ", "_")

proc newCodeNode*(name: string): CodeNode =
        result = CodeNode(name: name, authorsSection: CodeSectionNode(
                        kind: AuthorsNode), descriptionSection: CodeSectionNode(
                        kind: DescriptionNode))

macro defineCodes*(body: untyped): untyped =
        expectKind(body, nnkStmtList)
        result = body
        let codesArrayNode = newNimNode(nnkBracket)
        for b in body:
                case b.kind:
                of nnkCommand:
                        expectKind(b[1], nnkStrLit)
                        let codeNameNode = b[1]
                        codesArrayNode.add ident(
                                        codeNameNode.strVal.toSnakeCase)
                else:
                        continue
        let constName = postfix(ident("Codes"), "*")
        result.add newConstStmt(constName, codesArrayNode)


#[ macro defineCodes*(body: untyped): untyped =
        expectKind(body, nnkStmtList)
        result = body
        let codesArrayNode = newNimNode(nnkBracket)
        for b in body:
                case b.kind:
                of nnkCommand:
                        expectKind(b[1], nnkStrLit)
                        let codeNameNode = b[1]
                        codesArrayNode.add newCall(ident(codeNameNode.strVal.toSnakeCase))
                else:
                        continue
                let constName = postfix(ident("Codes"), "*")
                result.add newConstStmt(constName, codesArrayNode) ]#

        #[ macro createCode*(name: string, codeSection: untyped): untyped =
    expectKind(codeSection, nnkStmtList)
    result = newStmtList()
    let procBody = newStmtList()
    let tmp = ident("result")
    procBody.add newAssignment(tmp, newCall(bindSym"newCodeNode", name))
    for bodyNode in codeSection:
            procBody.add newCall(bindSym("add"),
            tmp.newDotExpr(ident("sections")), bodyNode)
    let procName = postfix(ident(($name).toSnakeCase), "*")
    result.add newProc(procName, [bindSym("CodeNode")], procBody) ]#

macro createCode*(name: string, codeSection: untyped): untyped =
        expectKind(codeSection, nnkStmtList)
        result = newStmtList()
        let procBody = newStmtList()
        let res = genSym(nskVar, "r")
        procBody.add newVarStmt(res, newCall(bindSym"newCodeNode", name))
        for bodyNode in codeSection:
                let bodyNodeRepr = bodyNode.repr
                if bodyNodeRepr.startsWith("authors"):
                        procBody.add newAssignment(res.newDotExpr(ident(
                                        "authorsSection")), bodyNode)
                elif bodyNodeRepr.startsWith("description"):
                        procBody.add newAssignment(res.newDotExpr(ident(
                                        "descriptionSection")), bodyNode)
                else:
                        procBody.add newCall(bindSym("add"),
                res.newDotExpr(ident("sections")), bodyNode)

        procBody.add res
        let procName = postfix(ident(($name).toSnakeCase), "*")
        let newProc = newBlockStmt(procBody)
        result.add newConstStmt(procName, newProc)

#[ macro ppc*(x: untyped): untyped =
        expectKind(x, nnkStmtList)
        let resultingCode = genSym(nskVar, "result")
        result = newStmtList()
        result.add newVarStmt(resultingCode, newStrLitNode(""))

        for i in 0 ..< x.len:
        let s = x[i]
        var ss = s.repr.replace(BacktickRegex, removeBackTicks)
        ss.removePrefix()
        let strLit = newStrLitNode(ss & "\n")
        let p = prefix(strLit, "&")
        let i = infix(resultingCode, "&=", p)
        result.add i
        result.add resultingCode ]#

macro ppc*(x: untyped): string =
        expectKind(x, nnkStmtList)
        result = newStmtList()
        let resultingCode = genSym(nskLet, "result")
        let strLit = toStrLit(x)
        var strVal = strLit.strVal
        strVal.removePrefix()
        strVal = strVal.replace("\"", "")
        strLit.strVal = strVal
        let p = prefix(strLit, "&")
        result.add newLetStmt(resultingCode, p)
        result.add resultingCode

template description*(a: string): CodeSectionNode =
        CodeSectionNode(kind: DescriptionNode, description: a)

template authors*(a: varargs[string]): CodeSectionNode =
        var n: CodeSectionNode = CodeSectionNode(kind: AuthorsNode)
        n.authors.add a
        n

template patchWrite32Bits*(target: string, b: untyped): CodeSectionNode =
        let code = ppc:
                b
        if countLines(code) > 2:
                raise newException(ValueError,
                                &"Patch type {Write32Bits} should only have one line of code")
        CodeSectionNode(kind: Write32BitsNode, targetAddress: target, code: code)

template patchInsertAsm*(target: string, b: untyped): CodeSectionNode =
        let code = ppc:
                b
        CodeSectionNode(kind: InsertAsmNode, targetAddress: target.toUpperAscii(), code: code)



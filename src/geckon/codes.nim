import macros, strutils

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
        path*: string
        authorsSection*: CodeSectionNode
        descriptionSection*: CodeSectionNode
        sections*: seq[CodeSectionNode]

func hasCodeSections*(codeNode: CodeNode): bool = codeNode.sections.len != 0

func toSnakeCase*(codeName: string): string = codeName.toLower().replace(" ", "_")

proc newCodeNode*(name: string, path: string): CodeNode =
        result = CodeNode(name: name, path: path, authorsSection: CodeSectionNode(
                        kind: AuthorsNode), descriptionSection: CodeSectionNode(
                        kind: DescriptionNode))

macro defineCodes*(body: untyped): untyped =
        expectKind(body, nnkStmtList)
        result = body
        let codesArrayNode = newNimNode(nnkBracket)
        for b in body:
                case b.kind:
                of nnkCommand:
                        expectKind(b[1], {nnkStrLit, nnkIdent})
                        let codeNameNode = b[1]
                        codesArrayNode.add ident(
                                        codeNameNode.strVal.toSnakeCase)
                else:
                        continue
        let constName = postfix(ident("Codes"), "*")
        result.add newConstStmt(constName, codesArrayNode)

macro createCode*(name: string, codeSection: untyped): untyped =
        expectKind(codeSection, nnkStmtList)
        result = newStmtList()
        let procBody = newStmtList()
        let res = genSym(nskVar, "r")
        let path = newDotExpr(newCall(ident("instantiationInfo"), newNimNode(nnkExprEqExpr).add(ident "fullPaths").add(ident("true"))), ident("filename"))
        procBody.add newVarStmt(res, newCall(bindSym"newCodeNode", name, path))
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
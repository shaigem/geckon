import macros, strutils

from strformat import `&`

export `&`, strip

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

func hasCodeSections*(codeNode: CodeNode): bool = codeNode.sections.len != 0

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

template `%`*(f: untyped): string =
        f
        
proc ppcImpl*(c, b: NimNode): NimNode =
        result = newStmtList()

        template addToString(a: untyped, newLineSuffix: string{lit} = "\n"): untyped =
                let code = infix(a, "&", newStrLitNode(newLineSuffix))
                let infix = infix(c, "&=", code)
                echo infix.repr
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
                        toStrNode.strVal= commandIdent.strVal
                else:
                        toStrNode.strVal= commandIdent.repr
                for i in 1 ..< b.len:
                        let toAppend = toStrNode.strVal & " " & b[i].repr & 
                                (if i == b.len - 1:
                                                "\n"
                                        else:
                                                ",")                                
                        toStrNode.strVal= toAppend
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
                        warning "invalid prefix char of " & prefixChar.strVal, b
        else:
                error "Invalid node kind: " & $b.kind & ", line: " & b.repr, b
                
macro ppc*(x: untyped): untyped =
        let resultingCode = genSym(nskVar, "result")
        result = newStmtList()
        result.add newVarStmt(resultingCode, newStrLitNode(""))
        result.add ppcImpl(resultingCode, x)
        result.add newCall(ident("strip"), resultingCode)

#[ macro ppc*(x: untyped): string =
        result = newStmtList()
        let resultingCode = genSym(nskLet, "result")
        let strLit = toStrLit(x)
        var strVal = strLit.strVal
        strVal.removePrefix()
        strVal = strVal.replace("\"", "")
        strLit.strVal = strVal
        let p = prefix(strLit, "&")
        result.add newLetStmt(resultingCode, p)
        result.add resultingCode ]#

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
import codes, gecko, system, osproc, os, std/tempfiles, std/with, strutils,
        sequtils, macros

const
    BaseAssemblerArguments = ["-a32", "-mbig", "-mregnames", "-mgekko"]
    BaseObjCopyArguments = ["-O", "binary", "$in", "$out"]
    AssemblerCmd = "powerpc-eabi-as"
    ObjCopyCmd = "powerpc-eabi-objcopy"
    TempDir = "./temp/"
    TempAsmExtension = ".asmtmp"
    TempElfExtension = ".o"
    NimFileExtension = ".nim"

type
    Assembler* = object
        codes: seq[CodeNode]
        args: seq[string]

proc getWorkingDir(resource: static string): static string =
    splitFile(instantiationInfo(0, fullPaths = true).filename).dir / resource

proc executeAssembleCommand(outPath: string, asmFilePath: string,
        args: openArray[string]): tuple[output: string, success: bool] =
    let args = args.join(" ") & " -o " & outPath
    let cmd = AssemblerCmd & " " & args & " " & asmFilePath
    let (output, returnCode) = execCmdEx(cmd)
    result = (output, returnCode == 0)

proc executeObjCopyCommand(elfOutPath: string): tuple[output: string,
        success: bool] =
    let args = BaseObjCopyArguments.join(" ") % ["in", elfOutPath, "out", elfOutPath]
    let cmd = ObjCopyCmd & " " & args
    let (output, returnCode) = execCmdEx(cmd)
    result = (output, returnCode == 0)

macro importFromImpl(dir: static string, recursive: bool): untyped =
    result = newStmtList()
    var moduleNames = newSeq[string]()

    template findCodes(d: untyped): untyped =
        let (p, name, ext) = splitFile(d)
        if ext != NimFileExtension:
            continue
        let fileData = slurp d
        if fileData.contains("defineCodes:"):
            moduleNames.add name
            result.add parseStmt("import " & joinPath(p, name))

    if recursive.boolVal:
        for d in walkDirRec($dir, relative = false, checkDir = true):
            findCodes d
    else:
        for _, d in walkDir($dir, relative = false, checkDir = true):
            findCodes d

    if moduleNames.len == 0:
        raise newException(CatchableError,
                "No modules/files were found in directory: " & dir)

    let arrayModuleNames = newNimNode(nnkBracket)
    for module in moduleNames:
        let modNode = newDotExpr(ident(module), ident("Codes"))
        arrayModuleNames.add modNode
    result.add arrayModuleNames

template importFrom*(dir: static string, recursive: bool = true): untyped =
    importFromImpl(getWorkingDir dir, recursive)

template includeAllCodes*(assembler: var Assembler,
        moduleCodes: untyped): untyped =
    for codes in moduleCodes:
        assembler.codes.add codes

template includeCodesFrom*(assembler: var Assembler, module: untyped): untyped =
    when declared module.Codes:
        assembler.codes.add module.Codes
    else:
        raise newException(CatchableError, "Module does not have a defineCodes block")

proc includeCode*(assembler: var Assembler, code: CodeNode) =
    assembler.codes.add code

proc initAssembler*(args: openArray[string] = BaseAssemblerArguments,
        codes: openArray[CodeNode] = []): Assembler =
    result = Assembler()
    result.args.add args
    result.codes.add codes

proc addArgs*(assembler: var Assembler, args: varargs[string]) =
    if args.len == 0:
        return
    assembler.args.add args

proc assemble*(assembler: Assembler): seq[GeckoCode] =
    let codes = assembler.codes
    if codes.len == 0:
        raise newException(CatchableError, "No codes to assemble")
    discard existsOrCreateDir(TempDir)
    result = newSeqOfCap[GeckoCode](codes.len)
    for codeToAssemble in codes:
        if not codeToAssemble.hasCodeSections():
            continue
        echo "Assembling code ", codeToAssemble.name, "..."
        var geckoCode = initGeckoCode(codeToAssemble.name,
                codeToAssemble.authorsSection.authors,
                codeToAssemble.descriptionSection.description)
        let codeNamePrefix = codeToAssemble.name.toLower().split(" ").mapIt(it[
                0]).join()
        let tempAssembleDir = createTempDir(codeNamePrefix, "", TempDir)

        # assemble each patch/section of the gecko code
        for section in codeToAssemble.sections:
            echo "section: type = ", section.kind, ", targetAddress = ",
                    section.targetAddress
            # first we must write out the asm code to a file
            let (tempAsmFile, tempAsmFilePath) = createTempFile("", "-" &
                    section.targetAddress & TempAsmExtension, tempAssembleDir)
            tempAsmFile.write(section.code)
            tempAsmFile.close()
            # now run the assembler command using the temp asm file

            var tempAssembledFilePath = tempAsmFilePath
            tempAssembledFilePath.removeSuffix(TempAsmExtension)
            tempAssembledFilePath &= TempElfExtension

            block assemble:
                let (output, success) = executeAssembleCommand(
                        tempAssembledFilePath, tempAsmFilePath, assembler.args)
                if not success:
                    raise newException(CatchableError,
                            "Could not assemble your asm codes. " & output)
            block copyOnlyBinary:
                let (output, success) = executeObjCopyCommand(tempAssembledFilePath)
                if not success:
                    raise newException(CatchableError,
                            "Could not perform obj copy on your asm codes. " & output)

            let assembledFile = open(tempAssembledFilePath, fmRead)
            defer: assembledFile.close()
            let codeType = initGeckoCodeType(($section.kind).toCodeTypeKind(),
                    section.targetAddress, assembledFile.readAll())
            geckoCode.codeTypes.add codeType

        defer: removeDir(tempAssembleDir, false)
        result.add geckoCode

template build*(b: untyped): untyped =
    var assembler = initAssembler()
    with assembler:
        b

template output*(a, b: untyped): untyped =
    var a: Assembler
    #let codes {.inject.} = a.assemble()
    let codes = a.assemble()
    with codes:
        b

# TODO check if list of codes have the same target address...
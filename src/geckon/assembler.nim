import codes, gecko, system, osproc, os, std/with, strutils,
        sequtils, macros

const
    BaseAssemblerArguments = ["-a32", "-mbig", "-mregnames", "-mgekko"]
    BaseObjCopyArguments = ["-O", "binary", "$in", "$out"]
    AssemblerCmd = "powerpc-eabi-as"
    ObjCopyCmd = "powerpc-eabi-objcopy"
    AsmDir = "./generated/"
    AsmExtension = ".asm"
    ElfExtension = ".o"
    NimFileExtension = ".nim"
    LowercaseLetters = 'a' .. 'z'
type
    Assembler* = object
        codes: seq[CodeNode]
        args: seq[string]
        keepObjFiles, keepAsmFiles: bool

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
    result = Assembler(keepObjFiles: true, keepAsmFiles: true)
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
    if dirExists(AsmDir):
        removeDir(AsmDir)
    createDir(AsmDir)
    result = newSeqOfCap[GeckoCode](codes.len)
    for codeToAssemble in codes:
        if not codeToAssemble.hasCodeSections():
            continue
        echo "Assembling code ", codeToAssemble.name, "..."
        var geckoCode = initGeckoCode(codeToAssemble.name,
                codeToAssemble.authorsSection.authors,
                codeToAssemble.descriptionSection.description)

        let (assembleDir, codeFileName, _) = AsmDir.joinPath(relativePath(codeToAssemble.path, getCurrentDir())).splitFile()
        let assembleCodeFilePath = assembleDir.joinPath(codeFileName)
        try:
            createDir(assembleDir)
        except:
            echo getCurrentExceptionMsg()
        # assemble each patch/section of the gecko code
        for section in codeToAssemble.sections:
            echo "section: type = ", section.kind, ", targetAddress = ",
                    section.targetAddress
            # TODO code name limit
            let codeNamePrefix = "_" & codeToAssemble.name.toLower().split(" ").filterIt(it[0] in LowercaseLetters).mapIt(it[
                0]).join() & "_" & section.targetAddress
            let assemblyFilePathNoExt = assembleCodeFilePath & codeNamePrefix
            let assemblyFilePath = assemblyFilePathNoExt & AsmExtension
            let assemblyObjFilePath = assemblyFilePathNoExt & ElfExtension
            # first we must write out the asm code to a file
            writeFile(assemblyFilePath, section.code)
            # now run the assembler command using the temp asm file
            block assemble:
                let (output, success) = executeAssembleCommand(
                        assemblyObjFilePath, assemblyFilePath, assembler.args)
                if not success:
                    raise newException(CatchableError,
                            "Could not assemble your asm codes. " & output)
            block copyOnlyBinary:
                let (output, success) = executeObjCopyCommand(assemblyObjFilePath)
                if not success:
                    raise newException(CatchableError,
                            "Could not perform obj copy on your asm codes. " & output)
            let assembledFile = open(assemblyObjFilePath, fmRead)
            let codeType = initGeckoCodeType(($section.kind).toCodeTypeKind(),
                    section.targetAddress, assembledFile.readAll())
            assembledFile.close()
            geckoCode.codeTypes.add codeType
            if not assembler.keepObjFiles:
                removeFile assemblyObjFilePath
            if not assembler.keepAsmFiles:
                removeFile assemblyFilePath
        result.add geckoCode

template build*(b: untyped): untyped =
    var assembler = initAssembler()
    with assembler:
        b

template output*(a, b: untyped): untyped =
    var a: Assembler
    let codes = a.assemble()
    with codes:
        b

# TODO check if list of codes have the same target address...
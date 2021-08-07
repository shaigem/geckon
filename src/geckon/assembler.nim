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

type
    Assembler* = object
        codes: seq[CodeNode]
        args: seq[string]

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

proc initAssembler*(args: openArray[string] = BaseAssemblerArguments,
        codes: openArray[CodeNode] = []): Assembler =
    result = Assembler()
    result.args.add args
    result.codes.add codes

proc addCodes*(assembler: var Assembler, codes: varargs[CodeNode]) =
    if codes.len == 0:
        return
    assembler.codes.add codes

proc addCode*(assembler: var Assembler, code: CodeNode) =
    assembler.codes.add code

proc addArgs*(assembler: var Assembler, args: varargs[string]) =
    if args.len == 0:
        return
    assembler.args.add args

template importAll*(assembler: var Assembler, b: untyped): untyped =
    assembler.codes.add b.Codes

proc assemble*(assembler: Assembler): seq[GeckoCode] =
    let codes = assembler.codes
    if codes.len == 0:
        raise newException(CatchableError, "No codes to assemble")
    discard existsOrCreateDir(TempDir)
    result = newSeqOfCap[GeckoCode](codes.len)
    for codeToAssemble in codes:

        var geckoCode = initGeckoCode(codeToAssemble.name,
                codeToAssemble.authorsSection.authors,
                codeToAssemble.descriptionSection.description)

        let codeNamePrefix = codeToAssemble.name.toLower().split(" ").mapIt(it[
                0]).join()
        let tempAssembleDir = createTempDir(codeNamePrefix, "", TempDir)

        # assemble each patch/section of the gecko code
        for section in codeToAssemble.sections:
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

        #defer: removeDir(tempAssembleDir, false)
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

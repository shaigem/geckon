import strutils, sequtils

const
    InstructionLength = 4
    InstructionLineLength = InstructionLength * 2
    InstructionHexStringLength = 8
    NopInstr = "60000000"
    EmptyInstr = "00000000"

type
    GeckoCode* = object
        name: string
        authors: seq[string]
        description: string
        codeTypes*: seq[GeckoCodeType]

    GeckoCodeTypeKind* {.pure.} = enum
        InsertAsm = "C2", Write32Bits = "04"

    GeckoCodeType* = object
        kind: GeckoCodeTypeKind
        targetAddress: string
        data: string

template addCodeLine(r, left, right: string) =
    r &= left & " " & right & "\n"

template addLine(r, content: string) =
    r &= content & "\n"

template addWithSpace(r, content: string) =
    r &= content & " "

proc instructionsCount(codeType: GeckoCodeType): int = (codeType.data.len /
        InstructionLength).int
proc instructionsLinesCount(codeType: GeckoCodeType): float =
    result = codeType.data.len / InstructionLineLength

proc initGeckoCode*(name: string, authors: openArray[string],
        description: string, codeTypes: openArray[GeckoCodeType] = []): GeckoCode =
    result = GeckoCode(name: name, description: description)
    result.authors.add authors
    result.codeTypes.add codeTypes

proc initGeckoCodeType*(kind: GeckoCodeTypeKind, targetAddress: string,
        data: string): GeckoCodeType =
    result = GeckoCodeType(kind: kind, targetAddress: targetAddress, data: data)

proc toCodeTypeKind*(k: string): GeckoCodeTypeKind =
    if k == $InsertAsm:
        InsertAsm
    elif k == $Write32Bits:
        Write32Bits
    else:
        raise newException(ValueError, "Invalid code type kind: " & k)

proc asFormattedOutput*(geckoCode: GeckoCode): string =
    result = "$" & geckoCode.name

    let authors = geckoCode.authors
    if authors.len > 0:
        result.addLine " " & "[" & authors.join(", ") & "]"
    else:
        result &= "\n"

    let description = geckoCode.description
    if not description.isEmptyOrWhitespace:
        result.addLine "*" & description

    for codeType in geckoCode.codeTypes:
        let dataLen = codeType.data.len
        if dataLen < InstructionLength:
            raise newException(ValueError, "Provided code type data is invalid or empty")

        let codeTypeBeginInstr = $codeType.kind & codeType.targetAddress[2 .. ^1]
        case codeType.kind:

        of Write32Bits:
            if dataLen > InstructionLength:
                raise newException(ValueError, "Code type 04 should contain only one instruction")
            result.addCodeLine codeTypeBeginInstr, codeType.data[0 ..< 4].toHex()

        of InsertAsm:
            let fillsLine = (dataLen mod InstructionLineLength) == 0
            var linesCount = ((codeType.instructionsLinesCount) + (
                    if fillsLine: 1.0 else: 0.5)).int
            let instrCount = codeType.instructionsCount

            result.addCodeLine codeTypeBeginInstr, $linesCount.toHex(InstructionHexStringLength)
            for pos in 1 .. instrCount:
                let addNewLine = (pos mod 2) == 0
                let readSlice = ((pos - 1) * InstructionLength) ..< (pos * InstructionLength)
                let instructionHex = codeType.data[readSlice].toHex()
                if addNewLine:
                    result.addLine instructionHex
                    continue
                result.addWithSpace instructionHex

            if fillsLine:
                result.addCodeLine NopInstr, EmptyInstr
            else:
                result.addLine EmptyInstr

proc asCombinedOutput*(geckoCodes: openArray[
        GeckoCode]): string = geckoCodes.mapIt(it.asFormattedOutput).join()

proc writeCodesToFile*(geckoCodes: openArray[GeckoCode], fileName: string) =
    writeFile(fileName, geckoCodes.asCombinedOutput)

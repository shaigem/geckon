import std/os
import strutils
import system
import osproc

when not defined(nimsuggest):
    const DevKitPro* = getEnv("DEVKITPRO")
    doAssert(DevKitPro != "", "DEVKITPRO environment variable is not set!")

const
    BaseAssembleArgs = ["-a32", "-mbig", "-mregnames", "-mgekko", "-I .include"]
    BaseObjCopyArgs = ["-O", "binary"]
    AssembleCmd = DevKitPro / "devkitPPC" / "bin" / "powerpc-eabi-as"
    ObjCopyCmd = DevKitPro / "devkitPPC" / "bin" / "powerpc-eabi-objcopy"

proc execAssemble*(inputFile: string; outputFile: string; args: varargs[string] = BaseAssembleArgs):  tuple[output: string, success: bool] =
    let args = args.join(" ") & " -o " & outputFile & " " & inputFile
    let cmd = AssembleCmd & " " & args
    let (output, returnCode) = execCmdEx(cmd)
    result = (output, returnCode == 0)

proc execObjCopy*(inputFile: string; outputFile: string; args: varargs[string] = BaseObjCopyArgs):  tuple[output: string, success: bool] =
    let args = args.join(" ") & " " & inputFile & " " & outputFile
    let cmd = ObjCopyCmd & " " & args
    let (output, returnCode) = execCmdEx(cmd)
    result = (output, returnCode == 0)
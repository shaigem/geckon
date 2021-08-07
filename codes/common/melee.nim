import geckon / [codes, common]

const
    FuncHsdRandi* = "0x80380580"

proc hsdRandi*(max: int, inclusive: bool = false, reg: Register = r12): string =
    let max = if inclusive: max + 1 else: max
    ppc:
        li r3, {max}
        {branchLink reg, FuncHsdRandi}

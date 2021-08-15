import geckon / [ppcasm, ppcutils]

const
    FuncHsdRandi* = "0x80380580"
    FuncSameTeamCheck* = "0x800a3844"
    ## FuncSameTeamCheck(r3 = SourceData, r4 = VictimData): bool
    ## if true: is on same team
    ## else: not on same team

proc hsdRandi*(max: int, inclusive: bool = false, reg: Register = r12): string =
    let max = if inclusive: max + 1 else: max
    ppc:
        li r3, {max}
        %branchLink(FuncHsdRandi, reg)

template branchToSameTeamCheck*(playerOneData, playerTwoData, result: string): string =
    ppc:
        %playerOneData
        %playerTwoData
        %branchLink(FuncSameTeamCheck)
        %result
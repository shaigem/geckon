import ppcasm

const BackupFreeSpaceOffset*: int16 = 0x38

template backup*(space: int16 = 0x78): string =
    ppc:
        mflr r0
        stw r0, 0x4(r1)
        stwu r1, -({BackupFreeSpaceOffset} + {space})(r1)
        stmw r20, 0x8(r1)

template restore*(space: int16 = 0x78): string =
    ppc:
        lmw r20, 0x8(r1)
        lwz r0, ({BackupFreeSpaceOffset} + 0x4 + {space})(r1)
        addi r1, r1, {BackupFreeSpaceOffset} + {space}
        mtlr r0

template load*(address: string, reg: Register = r12): string =
    ppc:
        lis {$reg}, {address} @h
        ori {$reg}, {$reg}, {address} @l

template branchLink*(address: string, reg: Register = r12): string =
    ppc:
        %load(address, reg)
        mtctr {$reg}
        bctrl

template branch*(address: string, reg: Register = r12): string =
    ppc:
        %load(address, reg)
        mtctr {$reg}
        bctr

template emptyBlock*(): string =
    block: ""

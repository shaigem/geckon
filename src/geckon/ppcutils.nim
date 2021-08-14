import ppcasm

template backup*(): string = 
    ppc:
        mflr r0
        stw r0, 0x4(r1)
        stwu r1,-(0x38 + 0x78)(r1) # make space for 12 registers
        stmw r20,0x8(r1)

template restore*(): string = 
    ppc:
        lmw r20,0x8(r1)
        lwz r0, (0x38 + 0x4 + 0x78)(r1)
        addi r1,r1,0x38 + 0x78
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
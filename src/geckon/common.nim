import codes, macros

type
    Register* {.pure.} = enum
        r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15,
                r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28,
                r29, r30, r31
        f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15,
                f16, f17, f18, f19, f20, f21, f22, f23, f24, f25, f26, f27, f28,
                f29, f30, f31

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

template EmptyBlock*(): string = 
    block: ""
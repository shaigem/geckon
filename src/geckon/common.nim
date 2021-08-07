import codes

type
    Register* {.pure.} = enum
        r12, f2, f1

template branchLink*(reg: Register, address: string): string =
    ppc:
        lis {$reg}, {address} @h
        ori {$reg}, {$reg}, {address} @l
        mtctr {$reg}
        bctrl
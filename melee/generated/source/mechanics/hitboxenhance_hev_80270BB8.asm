mr r3, r30
mr r4, r26
mr r5, r19
lis r12, 0x801510dc @h
ori r12, r12, 0x801510dc @l
mtctr r12
bctrl
Exit:
lwz r0, 0x00000CA0(r31)
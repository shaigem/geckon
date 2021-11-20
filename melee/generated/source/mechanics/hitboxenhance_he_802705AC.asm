mr r3, r29
mr r4, r24
mr r5, r26
lis r12, 0x801510dc @h
ori r12, r12, 0x801510dc @l
mtctr r12
bctrl
Exit:
lwz r0, 0x00000CA0(r30)
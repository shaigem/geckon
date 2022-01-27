lwz r3, 0x00000004(r26)
mr r4, r27
lis r12, 0x801510d4 @h
ori r12, r12, 0x801510d4 @l
mtctr r12
bctrl
cmplwi r3, 0
beq Exit
lbz r3, 16(r3)
rlwinm. r3, r3, 0, 2
beq Exit
lwz r5, 0x00000004(r26)
Exit:
lwz r3, 0x00000004(r26)
lwz r3, 0x00000008(r19)
lwz r4, 0x0000000C(r19)
lis r12, 0x801510d4 @h
ori r12, r12, 0x801510d4 @l
mtctr r12
bctrl
mr. r18, r3
lfs f22, 0x00000088(r27)
beq Exit
stw r3, 0x00000090(sp)
lbz r4, 16(r3)
rlwinm. r4, r4, 0, 128
beq Exit
UseSetWeight:
lwz r3, 0xFFFFAEB4(r13)
lfs f22, 0x0000010C(r3)
Exit:
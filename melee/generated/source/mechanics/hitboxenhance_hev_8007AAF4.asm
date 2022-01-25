lwz r0, 0x0000001C(r31)
cmplwi r0, 2
bne SetVars
lwz r3, 0xFFFFAEB4(r13)
lfs f0, 0x000001A4(r3)
stfs f0, 0x00001960(r25)
SetVars:
lwz r3, 0x00000008(r19)
mr r4, r30
lwz r5, 0x0000000C(r19)
lwz r6, 0x00000090(sp)
lis r12, 0x801510dc @h
ori r12, r12, 0x801510dc @l
mtctr r12
bctrl
li r0, 0
lwz r3, 0x00000004(r27)
mr r4, r28
lis r12, 0x801510d4 @h
ori r12, r12, 0x801510d4 @l
mtctr r12
bctrl
cmplwi r3, 0
beq Exit
lfs f0, 8(r3)
stfs f0, 11260(r29)
Exit:
lwz r0, 0x00000030(r28)
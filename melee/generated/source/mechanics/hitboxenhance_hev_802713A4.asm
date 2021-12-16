lwz r0, 0(r29)
cmpwi r0, 0
beq Exit
mr r3, r27
mr r4, r29
lis r12, 0x801510ec @h
ori r12, r12, 0x801510ec @l
mtctr r12
bctrl
Exit:
lwz r0, 0(r29)
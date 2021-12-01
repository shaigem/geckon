lwz r0, 0(r31)
cmpwi r0, 0
beq Exit
stw r3, 0x0000001C(sp)
lwz r3, 0(r3)
mr r5, r4
mr r4, r3
lis r12, 0x801510d4 @h
ori r12, r12, 0x801510d4 @l
mtctr r12
bctrl
cmplwi r3, 0
beq Exit
stw r3, 0x00000020(sp)
lwz r3, 0x0000001C(sp)
Exit:
lwz r0, 0(r31)
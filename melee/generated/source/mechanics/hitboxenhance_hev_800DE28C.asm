lwz r3, 0(r28)
lwz r4, 0(r30)
addi r5, r28, 0x00000DF4
addi r6, r28, 9328
lis r12, 0x801510dc @h
ori r12, r12, 0x801510dc @l
mtctr r12
bctrl
lfs f1, 0x00001960(r30)
mr r3, r30
lwz r4, 0x00000E24(r28)
lwz r5, 0x00000DFC(r28)
lwz r6, 0x00000010(r30)
lis r12, 0x80090594 @h
ori r12, r12, 0x80090594 @l
mtctr r12
bctrl
lhz r0, 0x000018FA(r30)
cmplwi r0, 0
beq Exit
li r3, 1
lbz r0, 9360(r30)
rlwimi r0, r3, 3, 8
stb r0, 9360(r30)
Exit:
lwz r0, 0x00000094(sp)
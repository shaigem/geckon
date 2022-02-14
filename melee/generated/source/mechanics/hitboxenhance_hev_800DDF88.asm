mr r3, r24
mr r4, r25
addi r5, r31, 0x00000DF4
addi r6, r31, 9760
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
lbz r0, 11084(r30)
rlwimi r0, r3, 3, 8
stb r0, 11084(r30)
Exit:
lbz r0, 0x00002226(r27)
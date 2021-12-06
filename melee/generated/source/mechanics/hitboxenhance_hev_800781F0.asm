mr r3, r26
mr r4, r27
li r5, 1492
li r6, 316
li r7, 4044
lis r12, 0x801510d8 @h
ori r12, r12, 0x801510d8 @l
mtctr r12
bctrl
cmplwi r3, 0
beq Exit
lwz r0, 0(r3)
cmpwi r0, 0
bne Exit
li r25, 0
Exit:
lbz r0, 0x0000221C(r28)
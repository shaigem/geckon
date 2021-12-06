mr r3, r26
mr r4, r27
li r5, 2324
li r6, 312
li r7, 9196
lis r12, 0x801510d8 @h
ori r12, r12, 0x801510d8 @l
mtctr r12
bctrl
cmplwi r3, 0
beq Exit
stw r3, 0x00000040(sp)
lwz r25, 0(r3)
cmpwi r25, 0
bne Exit
li r24, 0
Exit:
li r25, 0
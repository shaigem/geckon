lwz r3, 0x00000040(sp)
cmplwi r3, 0
beq Exit
lwz r0, 0(r3)
cmpwi r0, 0
bne Exit
li r24, 0
Exit:
lbz r0, 0x0000221C(r28)
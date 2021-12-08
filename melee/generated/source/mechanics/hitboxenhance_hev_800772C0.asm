lwz r3, 0x00000040(sp)
cmplwi r3, 0
beq Exit
lwz r0, 0(r3)
cmpwi r0, 0
bne Exit
li r24, 0
lbz r3, 0x00002219(r28)
rlwimi r3, r24, 2, 29, 29
stb r3, 0x00002219(r28)
stw r24, 0x00001954(r28)
stw r24, 0x0000195C(r28)
Exit:
lbz r0, 0x0000221C(r28)
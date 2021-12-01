lwz r3, 0x00000020(sp)
cmplwi r3, 0
beq Exit
lbz r3, 16(r3)
rlwinm. r3, r3, 0, 27, 27
beq Exit
li r0, 0
stw r0, 0x00000010(sp)
stw r0, 0x00000014(sp)
stw r0, 0x00000018(sp)
Exit:
lwz r3, 0x00000048(r31)
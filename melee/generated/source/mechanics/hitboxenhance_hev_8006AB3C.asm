lhz r0, 0x00002098(r31)
cmplwi r0, 0
beq Exit
lbz r0, 0x0000221C(r31)
rlwinm. r0, r0, 31, 31, 31
bne Exit
li r3, 0
lbz r0, 11264(r31)
rlwimi r0, r3, 6, 64
stb r0, 11264(r31)
Exit:
lbz r0, 0x0000221C(r31)
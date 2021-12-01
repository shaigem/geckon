lwz r3, 0x00000020(sp)
cmplwi r3, 0
beq OriginalExit
lbz r3, 16(r3)
rlwinm. r3, r3, 0, 27, 27
beq OriginalExit
lwz r3, 0x00000010(r31)
lwz r4, 0x00000014(r31)
stw r3, 0x00000010(sp)
stw r4, 0x00000014(sp)
lwz r4, 0x00000018(r31)
stw r4, 0x00000018(sp)
lwz r3, 0x00000048(r31)
addi r4, sp, 16
addi r5, r31, 0x00000058
lis r12, 0x8000B1CC @h
ori r12, r12, 0x8000B1CC @l
mtctr r12
bctrl
lis r12, 0x8007ae6c @h
ori r12, r12, 0x8007ae6c @l
mtctr r12
bctr
OriginalExit:
stw r0, 0(r31)
lwz r4, 0x00000020(sp)
cmplwi r4, 0
beq OriginalExit
lbz r4, 16(r4)
rlwinm. r4, r4, 0, 27, 27
beq OriginalExit
mr r6, r3
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
mr r3, r6
lis r12, 0x8007ae04 @h
ori r12, r12, 0x8007ae04 @l
mtctr r12
bctr
OriginalExit:
stw r0, 0x00000060(r31)
cmpwi r28, 0x0000003D
bne+ OriginalExit
lwz r3, 0x00000008(r29)
lbz r4, 0x00000001(r3)
rlwinm r4, r4, 27, 29, 31
mulli r4, r4, 312
addi r4, r4, 2324
add r4, r30, r4
lhz r5, 0x00000040(r4)
lbz r6, 0x00000002(r3)
rlwimi r5, r6, 4, 20, 27
sth r5, 0x00000040(r4)
lbz r5, 0x00000041(r4)
lbz r6, 0x00000003(r3)
rlwimi r5, r6, 28, 28, 28
stb r5, 0x00000041(r4)
lbz r5, 0x00000041(r4)
lbz r6, 0x00000003(r3)
rlwimi r5, r6, 28, 29, 29
stb r5, 0x00000041(r4)
lbz r5, 0x00000041(r4)
lbz r6, 0x00000003(r3)
rlwimi r5, r6, 28, 30, 30
stb r5, 0x00000041(r4)
lbz r5, 0x00000042(r4)
lbz r6, 0x00000003(r3)
rlwimi r5, r6, 4, 25, 25
stb r5, 0x00000042(r4)
lbz r5, 0x00000042(r4)
lbz r6, 0x00000003(r3)
rlwimi r5, r6, 4, 26, 26
stb r5, 0x00000042(r4)
Exit:
addi r3, r3, 4
stw r3, 0x00000008(r29)
lis r12, 0x8007332c @h
ori r12, r12, 0x8007332c @l
mtctr r12
bctr
OriginalExit:
add r3, r31, r0
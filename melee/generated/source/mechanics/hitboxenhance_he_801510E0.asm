cmpwi r4, 343
beq- OriginalExit
lwz r3, 0x00000008(r29)
lbz r4, 0x00000003(r3)
mulli r4, r4, 20
add r4, r4, r5
add r4, r30, r4
lwz r6, 0xFFFFAEB4(r13)
lfs f1, 0x000000F4(r6)
psq_l f0, 0x00000004(r3), 0, 5
ps_mul f0, f1, f0
psq_st f0, 0(r4), 0, 7
psq_l f0, 0x00000008(r3), 1, 5
stfs f0, 8(r4)
lbz r6, 0x0000000A(r3)
rlwinm. r0, r6, 0, 24, 24
li r0, 1
bne IsWindBox
b CheckFlippy
IsWindBox:
lbz r5, 12(r4)
rlwimi r5, r0, 0, 1
stb r0, 12(r4)
CheckFlippy:
rlwinm. r6, r6, 0, 25, 25
bne StoreFlippyType
rlwinm. r6, r6, 0, 26, 26
li r0, 2
bne StoreFlippyType
li r0, 0
StoreFlippyType:
stw r0, 16(r4)
addi r3, r3, 12
stw r3, 0x00000008(r29)
blr
OriginalExit:
fmr f3, f1
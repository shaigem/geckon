cmpwi r4, 343
beq- OriginalExit
stwu sp, 0xFFFFFFB0(sp)
lwz r3, 0x00000008(r29)
lbz r4, 0x00000001(r3)
rlwinm. r4, r4, 0, 27, 27
bne ApplyToAllPreviousHitboxes
li r0, 1
rlwinm r4, r4, 27, 29, 31
ApplyToAllPreviousHitboxes:
li r0, 4
li r4, 0
mtctr r0
mulli r4, r4, 24
add r4, r4, r5
add r4, r30, r4
lwz r6, 0xFFFFAEB4(r13)
lfs f1, 0x000000F4(r6)
lhz r6, 0x00000001(r3)
rlwinm r6, r6, 0, 0x00000FFF
sth r6, 0x00000044(sp)
lhz r6, 0x00000003(r3)
rlwinm r6, r6, 28, 0x00000FFF
sth r6, 0x00000046(sp)
psq_l f0, 0x00000044(sp), 0, 5
ps_mul f0, f1, f0
psq_st f0, 0(r4), 0, 7
psq_l f1, 0x000000F4(r6), 1, 7
lhz r6, 0x00000004(r3)
rlwinm r6, r6, 0, 0x00000FFF
sth r6, 0x00000040(sp)
lha r6, 0x00000006(r3)
xoris r6, r6, 0x00008000
sth r6, 0x00000042(sp)
psq_l f0, 0x00000040(r3), 0, 5
addi r3, r3, 8
stw r3, 0x00000008(r29)
addi sp, sp, 80
blr
OriginalExit:
fmr f3, f1
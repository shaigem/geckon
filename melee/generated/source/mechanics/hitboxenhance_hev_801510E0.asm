cmpwi r4, 343
beq- OriginalExit
stwu sp, 0xFFFFFFB0(sp)
lwz r3, 0x00000008(r29)
li r0, 1
mtctr r0
lhz r0, 0(r27)
cmplwi r0, 0x00000006
lbz r0, 0x00000001(r3)
rlwinm r4, r0, 27, 29, 31
beq CheckApplyToPrevious
cmplwi r4, 7
bne+ CheckApplyToPrevious
addi r4, r30, 9328
b BeginReadData
CheckApplyToPrevious:
rlwinm. r0, r0, 0, 27, 27
beq CalculateExtHit
li r0, 4
mtctr r0
li r4, 0
CalculateExtHit:
mulli r4, r4, 20
add r4, r4, r5
add r4, r30, r4
BeginReadData:
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
lwz r6, 0xFFFFAEB4(r13)
psq_l f1, 0x000000F4(r6), 1, 7
lhz r6, 0x00000004(r3)
rlwinm r6, r6, 0, 0x00000FFF
sth r6, 0x00000040(sp)
lbz r6, 0x00000006(r3)
slwi r6, r6, 24
srawi r6, r6, 24
sth r6, 0x00000042(sp)
psq_l f0, 0x00000040(sp), 0, 5
ps_mul f0, f1, f0
psq_st f0, 8(r4), 0, 7
lbz r6, 0x00000007(r3)
stb r6, 16(r4)
bdnz+ CopyToAllHitboxes
b Exit
CopyToAllHitboxes:
addi r6, r4, 20
Loop:
lwz r0, 0(r4)
stw r0, 0(r6)
lwz r0, 4(r4)
stw r0, 4(r6)
lwz r0, 8(r4)
stw r0, 8(r6)
lwz r0, 12(r4)
stw r0, 12(r6)
lwz r0, 16(r4)
stw r0, 16(r6)
addi r6, r6, 20
bdnz+ Loop
Exit:
addi r3, r3, 8
stw r3, 0x00000008(r29)
addi sp, sp, 80
blr
OriginalExit:
fmr f3, f1
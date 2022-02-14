cmpwi r4, 343
beq- OriginalExit
mflr r0
stw r0, 0x00000004(sp)
stwu sp, 0xFFFFFFB0(sp)
lwz r9, 0x00000008(r29)
li r10, 0
cmplwi r4, 0
bne BeginReadData
CheckApplyToPrevious:
lbz r0, 0x00000001(r9)
rlwinm. r10, r0, 0, 27, 27
rlwinm r3, r0, 27, 29, 31
beq CalculateHitStructs
li r3, 0
CalculateHitStructs:
mullw r4, r3, r7
cmplwi r3, 4
blt CalcNormal
add r4, r4, r8
CalcNormal:
add r4, r4, r6
add r4, r30, r4
mulli r3, r3, 64
add r3, r3, r5
add r3, r30, r3
BeginReadData:
lwz r5, 0xFFFFAEB4(r13)
lfs f1, 0x000000F4(r5)
lhz r5, 0x00000001(r9)
rlwinm r5, r5, 0, 0x00000FFF
sth r5, 0x00000044(sp)
lhz r5, 0x00000003(r9)
rlwinm r5, r5, 28, 0x00000FFF
sth r5, 0x00000046(sp)
psq_l f0, 0x00000044(sp), 0, 5
ps_mul f0, f1, f0
psq_st f0, 0(r3), 0, 7
lwz r5, 0xFFFFAEB4(r13)
psq_l f1, 0x000000F4(r5), 1, 7
lhz r5, 0x00000004(r9)
rlwinm r5, r5, 0, 0x00000FFF
sth r5, 0x00000040(sp)
lbz r5, 0x00000006(r9)
slwi r5, r5, 24
srawi r5, r5, 24
sth r5, 0x00000042(sp)
psq_l f0, 0x00000040(sp), 0, 5
ps_mul f0, f1, f0
psq_st f0, 8(r3), 0, 7
lbz r0, 0x00000007(r9)
stb r0, 16(r3)
bl SetBaseDamage
cmplwi r10, 0
beq Exit
CopyToAllHitboxes:
li r10, 1
addi r5, r3, 64
add r4, r4, r7
Loop:
cmpwi r10, 4
bne Body
add r4, r4, r8
Body:
lwz r0, 0(r3)
stw r0, 0(r5)
lwz r0, 4(r3)
stw r0, 4(r5)
lwz r0, 8(r3)
stw r0, 8(r5)
lwz r0, 12(r3)
stw r0, 12(r5)
lbz r0, 16(r3)
stb r0, 16(r5)
bl SetBaseDamage
addi r5, r5, 64
add r4, r4, r7
addi r10, r10, 1
cmplwi r10, 8
blt+ Loop
Exit:
addi r9, r9, 8
stw r9, 0x00000008(r29)
lwz r0, 0x00000054(sp)
addi sp, sp, 0x00000050
mtlr r0
blr
SetBaseDamage:
rlwinm. r0, r0, 0, 2
beq Return_SetStaling
lwz r0, 0x00000008(r4)
sth r0, 0x00000040(sp)
psq_l f1, 0x00000040(sp), 1, 5
stfs f1, 0x0000000C(r4)
Return_SetStaling:
blr
OriginalExit:
fmr f3, f1
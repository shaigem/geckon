cmpwi r4, 343
beq- OriginalExit
ParseBegin:
mflr r0
stw r0, 0x00000004(sp)
stwu sp, 0xFFFFFFB0(sp)
stw r31, 0x0000004C(sp)
stw r26, 0x00000048(sp)
stw r25, 0x00000044(sp)
stw r24, 0x00000040(sp)
stw r23, 0x0000003C(sp)
stw r22, 0x00000038(sp)
stw r21, 0x00000034(sp)
lwz r31, 0x00000008(r29)
mr r26, r5
mr r25, r6
mr r24, r7
mr r23, r8
li r22, 0
li r21, 0
cmplwi r3, 0
beq ParseHeader
cmplwi r4, 0
bne ParseEventData
ParseHeader:
lbz r0, 0x00000001(r31)
rlwinm r3, r0, 27, 29, 31
rlwinm. r21, r0, 0, 27, 27
beq GetHitStructPtrs
FindActiveHitboxes:
li r3, 0
b GetHitStructPtrs
FindActiveHitboxes_Check:
lwz r0, 0(r4)
cmpwi r0, 0
beq FindActiveHitboxes_Next
cmplwi r26, 0
beq ParseEventData
li r0, 5
mtctr r0
subi r5, r26, 4
subi r6, r3, 4
ExtHitCopy:
lwzu r0, 0x00000004(r5)
stwu r0, 0x00000004(r6)
bdnz+ ExtHitCopy
b ParseEventData_SetNormalHitboxValues
FindActiveHitboxes_Next:
addi r22, r22, 1
cmplwi r22, 4
bne Advance
add r4, r4, r23
Advance:
cmplwi r22, 8
add r4, r4, r24
addi r3, r3, 20
blt FindActiveHitboxes_Check
b Exit
GetHitStructPtrs:
mullw r4, r3, r24
cmplwi r3, 4
blt CalcNormal
add r4, r4, r23
CalcNormal:
add r4, r4, r25
add r4, r30, r4
mulli r3, r3, 20
add r3, r3, r26
add r3, r30, r3
li r26, 0
cmpwi r21, 0
bne FindActiveHitboxes_Check
ParseEventData:
lwz r5, 0xFFFFAEB4(r13)
lfs f1, 0x000000F4(r5)
lhz r5, 0x00000001(r31)
rlwinm r5, r5, 0, 0x00000FFF
sth r5, 0x00000024(sp)
lhz r5, 0x00000003(r31)
rlwinm r5, r5, 28, 0x00000FFF
sth r5, 0x00000026(sp)
psq_l f0, 0x00000024(sp), 0, 5
ps_mul f0, f1, f0
psq_st f0, 0(r3), 0, 7
lwz r5, 0xFFFFAEB4(r13)
psq_l f1, 0x000000F4(r5), 1, 7
lhz r5, 0x00000004(r31)
rlwinm r5, r5, 0, 0x00000FFF
sth r5, 0x00000024(sp)
lbz r5, 0x00000006(r31)
slwi r5, r5, 24
srawi r5, r5, 24
sth r5, 0x00000026(sp)
psq_l f0, 0x00000024(sp), 0, 5
ps_mul f0, f1, f0
psq_st f0, 8(r3), 0, 7
lbz r0, 0x00000007(r31)
stb r0, 16(r3)
mr r26, r3
ParseEventData_SetNormalHitboxValues:
lbz r0, 0x00000007(r31)
rlwinm. r0, r0, 0, 2
beq ParseEventData_End
lwz r0, 0x00000008(r4)
sth r0, 0x00000024(sp)
psq_l f1, 0x00000024(sp), 1, 5
stfs f1, 0x0000000C(r4)
ParseEventData_End:
cmpwi r21, 0
bne FindActiveHitboxes_Next
Exit:
addi r31, r31, 8
stw r31, 0x00000008(r29)
lwz r0, 0x00000054(sp)
lwz r31, 0x0000004C(sp)
lwz r26, 0x00000048(sp)
lwz r25, 0x00000044(sp)
lwz r24, 0x00000040(sp)
lwz r23, 0x0000003C(sp)
lwz r22, 0x00000038(sp)
lwz r21, 0x00000034(sp)
addi sp, sp, 0x00000050
mtlr r0
blr
OriginalExit:
fmr f3, f1
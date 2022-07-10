cmpwi r4, 343
beq- OriginalExit
cmplwi r3, 0
beq Invalid
cmplwi r4, 0
beq Invalid
stwu sp, 0xFFFFFFE8(sp)
li r0, 4
stw r0, 0x00000014(sp)
li r0, 4
mtctr r0
lhz r0, 0(r3)
lwz r3, 0x0000002C(r3)
cmplwi r0, 4
beq GetExtHitForFighter
cmplwi r0, 6
beq GetExtHitForItem
b Invalid
GetExtHitForItem:
addi r5, r3, 4404
stw r5, 0x00000010(sp)
addi r5, r3, 1492
addi r3, r3, 4048
li r0, 316
b GetExtHit
GetExtHitForFighter:
addi r5, r3, 9692
stw r5, 0x00000010(sp)
addi r5, r3, 2324
addi r3, r3, 9248
li r0, 312
GetExtHit:
b GetExtHit_Comparison
GetExtHit_Loop:
add r5, r5, r0
addi r3, r3, 84
GetExtHit_Comparison:
cmplw r5, r4
bdnzf eq, GetExtHit_Loop
beq Exit
lwz r5, 0x00000014(sp)
cmplwi r5, 0
beq Invalid
mtctr r5
li r5, 0
stw r5, 0x00000014(sp)
lwz r5, 0x00000010(sp)
b GetExtHit_Loop
Invalid:
li r3, 0
Exit:
addi sp, sp, 0x00000018
blr
OriginalExit:
lwz r31, 0x0000002C(r3)
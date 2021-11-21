cmpwi r4, 343
beq- OriginalExit
cmplwi r3, 0
beq Invalid
cmplwi r4, 0
beq Invalid
cmplwi r5, 0
beq Invalid
mflr r0
stw r0, 0x00000004(r1)
stwu r1, -(56 + 120)(r1)
stmw r20, 0x00000008(r1)
mr r31, r3
mr r30, r4
mr r29, r5
lwz r28, 0x0000002C(r3)
lwz r27, 0x0000002C(r4)
lhz r3, 0(r3)
cmplwi r3, 4
beq GetExtHitForFighter
cmplwi r3, 6
beq GetExtHitForItem
b Invalid
GetExtHitForItem:
li r3, 1492
li r4, 316
li r5, 4044
b GetExtHit
GetExtHitForFighter:
li r3, 2324
li r4, 312
li r5, 9196
GetExtHit:
li r26, 4
mtctr r26
add r26, r28, r3
add r3, r28, r5
b Comparison
Loop:
add r26, r26, r4
addi r3, r3, 24
Comparison:
cmplw r26, r29
bdnzf eq, Loop
beq Exit
Invalid:
li r3, 0
Exit:
lmw r20, 0x00000008(r1)
lwz r0, (56 + 0x00000004 + 120)(r1)
addi r1, r1, 56 + 120
mtlr r0
blr
OriginalExit:
lwz r31, 0x0000002C(r3)
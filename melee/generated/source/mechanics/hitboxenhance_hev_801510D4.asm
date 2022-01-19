cmpwi r4, 343
beq- OriginalExit
cmplwi r3, 0
beq Invalid
cmplwi r4, 0
beq Invalid
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
addi r5, r3, 1492
addi r3, r3, 4048
li r0, 316
b GetExtHit
GetExtHitForFighter:
addi r5, r3, 2324
addi r3, r3, 9248
li r0, 312
GetExtHit:
b Comparison
Loop:
add r5, r5, r0
addi r3, r3, 20
Comparison:
cmplw r5, r4
bdnzf eq, Loop
beq Exit
Invalid:
li r3, 0
Exit:
blr
OriginalExit:
lwz r31, 0x0000002C(r3)
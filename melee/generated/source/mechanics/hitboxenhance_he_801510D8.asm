cmpwi r4, 343
beq- OriginalExit
add r7, r3, r5
li r5, 0
b Comparison
Loop:
addi r5, r5, 1
cmpwi r5, 3
bgt- NotFound
add r7, r7, r6
Comparison:
cmplw r7, r4
bne+ Loop
Found:
mulli r5, r5, 20
addi r5, r5, 9196
add r5, r3, r5
mr r3, r5
blr
NotFound:
li r3, 0
blr
OriginalExit:
lfs f1, 0xFFFFA4C0(rtoc)
subi r0, r28, 10
cmpwi r28, 0x0000003C
bne OriginalExit
lwz r3, 0x00000008(r29)
lbz r3, 0x00000007(r3)
rlwinm. r3, r3, 0, 1
li r3, 0
li r4, 0
beq ReadEvent_CustomEvent
addi r3, r30, 9408
addi r4, r30, 0x00000DF4
ReadEvent_CustomEvent:
li r5, 9248
li r6, 2324
li r7, 312
li r8, 5856
lis r12, 0x801510e0 @h
ori r12, r12, 0x801510e0 @l
mtctr r12
bctrl
lis r12, 0x80073450 @h
ori r12, r12, 0x80073450 @l
mtctr r12
bctr
OriginalExit:
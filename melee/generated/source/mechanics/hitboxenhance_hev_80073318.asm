cmpwi r28, 0x0000003C
bne+ OriginalExit
lwz r3, 0x00000008(r29)
lbz r3, 0x00000001(r3)
rlwinm r3, r3, 27, 29, 31
cmplwi r3, 7
li r3, 0
bne ReadEvent
addi r3, r30, 9328
addi r4, r30, 0x00000DF4
ReadEvent:
li r5, 9248
li r6, 2324
li r7, 312
lis r12, 0x801510e0 @h
ori r12, r12, 0x801510e0 @l
mtctr r12
bctrl
lis r12, 0x8007332c @h
ori r12, r12, 0x8007332c @l
mtctr r12
bctr
OriginalExit:
lwz r12, 0(r3)
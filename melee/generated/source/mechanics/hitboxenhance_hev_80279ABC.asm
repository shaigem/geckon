cmpwi r28, 0x0000003C
bne+ OriginalExit
li r3, 0
li r4, 0
li r5, 4048
li r6, 1492
li r7, 316
li r8, 1452
lis r12, 0x801510e0 @h
ori r12, r12, 0x801510e0 @l
mtctr r12
bctrl
lis r12, 0x80279ad0 @h
ori r12, r12, 0x80279ad0 @l
mtctr r12
bctr
OriginalExit:
lwz r12, 0(r3)
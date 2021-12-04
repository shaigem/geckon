cmpwi r28, 0x0000003C
bne+ OriginalExit
li r5, 9244
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
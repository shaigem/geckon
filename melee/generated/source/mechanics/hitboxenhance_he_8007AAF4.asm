lwz r3, 0x00000008(r19)
mr r4, r30
lwz r5, 0x0000000C(r19)
lis r12, 0x801510dc @h
ori r12, r12, 0x801510dc @l
mtctr r12
bctrl
lis r12, 0x8007ab0c @h
ori r12, r12, 0x8007ab0c @l
mtctr r12
bctr
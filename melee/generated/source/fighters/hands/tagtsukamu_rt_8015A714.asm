lwz r0, 0x00002360(r31)
cmpwi r0, 1
bne Exit
mr r3, r30
lis r12, 0x801510c0 @h
ori r12, r12, 0x801510c0 @l
mtctr r12
bctrl
lis r12, 0x8015a738 @h
ori r12, r12, 0x8015a738 @l
mtctr r12
bctr
Exit:
lfs f0, 0xFFFFA798(rtoc)
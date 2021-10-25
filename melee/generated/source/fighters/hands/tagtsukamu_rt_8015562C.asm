lwz r0, 0x00002360(r31)
cmpwi r0, 1
bne Exit
mr r3, r30
lis r12, 0x801510c0 @h
ori r12, r12, 0x801510c0 @l
mtctr r12
bctrl
lis r12, 0x80155644 @h
ori r12, r12, 0x80155644 @l
mtctr r12
bctr
Exit:
mr r3, r30
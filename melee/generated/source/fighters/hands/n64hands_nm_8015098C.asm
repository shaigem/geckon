mr r3, r30
lis r12, 0x801521DC @h
ori r12, r12, 0x801521DC @l
mtctr r12
bctrl
lis r12, 0x801509B8 @h
ori r12, r12, 0x801509B8 @l
mtctr r12
bctr
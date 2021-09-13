lis r3, 0x00008015
addi r4, r3, 28524
addi r3, r31, 0
lis r12, 0x80156F6C @h
ori r12, r12, 0x80156F6C @l
mtctr r12
bctrl
lis r12, 0x801566dc @h
ori r12, r12, 0x801566dc @l
mtctr r12
bctr
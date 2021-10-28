stfs f0, 0x0000002C(sp)
mr r3, r31
lis r4, 0x8015aac8 @h
ori r4, r4, 0x8015aac8 @l
addi r5, sp, 36
lis r12, 0x8015Ba34 @h
ori r12, r12, 0x8015Ba34 @l
mtctr r12
bctrl
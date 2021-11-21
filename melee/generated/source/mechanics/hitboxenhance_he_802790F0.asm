mulli r3, r4, 24
addi r3, r3, 4044
add r3, r30, r3
mr r28, r4
lis r12, 0x801510e4 @h
ori r12, r12, 0x801510e4 @l
mtctr r12
bctrl
mr r4, r28
Exit:
mulli r3, r4, 316
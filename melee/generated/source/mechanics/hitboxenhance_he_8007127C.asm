mulli r3, r0, 24
addi r3, r3, 9196
add r3, r31, r3
mr r5, r4
lis r12, 0x801510e4 @h
ori r12, r12, 0x801510e4 @l
mtctr r12
bctrl
mr r4, r5
Exit:
mulli r3, r0, 312
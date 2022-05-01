mulli r3, r0, 64
addi r3, r3, 9248
add r3, r31, r3
lis r12, 0x801510e4 @h
ori r12, r12, 0x801510e4 @l
mtctr r12
bctrl
Exit:
lwz r0, 0(r30)
mulli r3, r4, 84
addi r3, r3, 4048
add r3, r30, r3
lis r12, 0x801510e4 @h
ori r12, r12, 0x801510e4 @l
mtctr r12
bctrl
Exit:
lwz r0, 0(r29)
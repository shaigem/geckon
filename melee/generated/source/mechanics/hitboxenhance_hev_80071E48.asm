cmplwi r0, 1
bge Exit
addi r3, r6, 9888
lis r12, 0x801510e4 @h
ori r12, r12, 0x801510e4 @l
mtctr r12
bctrl
stw r0, 0(r3)
Exit:
addi r3, r31, 0
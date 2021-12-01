lwz r3, 0x00000010(r31)
lwz r4, 0x00000014(r31)
stw r3, 0x00000010(sp)
stw r4, 0x00000014(sp)
lwz r4, 0x00000018(r31)
stw r4, 0x00000018(sp)
lwz r3, 0x00000048(r31)
addi r4, sp, 16
addi r5, r31, 0x00000058
lis r12, 0x8000B1CC @h
ori r12, r12, 0x8000B1CC @l
mtctr r12
bctrl
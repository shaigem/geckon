addi r29, r3, 0
li r4, 4044
lis r12, 0x8000c160 @h
ori r12, r12, 0x8000c160 @l
mtctr r12
bctrl
Exit:
mr r3, r29
mr. r6, r3
mr r3, r27
mr r4, r28
li r5, 1492
li r6, 316
li r7, 4048
lis r12, 0x801510d8 @h
ori r12, r12, 0x801510d8 @l
mtctr r12
bctrl
cmpwi r3, 0
beq Exit
lfs f0, 8(r3)
stfs f0, 9336(r29)
Exit:
mr r6, r30
stw r0, 0x000019B0(r29)
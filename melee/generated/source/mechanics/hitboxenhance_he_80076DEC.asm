mr r0, r3
mr r3, r29
mr r4, r30
li r5, 2324
li r6, 312
li r7, 9196
lis r12, 0x801510d8 @h
ori r12, r12, 0x801510d8 @l
mtctr r12
bctrl
cmpwi r3, 0
beq Exit
lfs f0, 8(r3)
stfs f0, 9300(r31)
Exit:
mr r3, r0
lwz r0, 0x00000030(r30)
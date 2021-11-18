mr r3, r12
lwz r4, 0x0000000C(r17)
li r5, 2324
li r6, 312
lis r7, 0x801510d8 @h
ori r7, r7, 0x801510d8 @l
mtctr r7
bctrl
cmpwi r3, 0
beq OriginalExit
lwz r0, 0x0000001C(r31)
cmplwi r0, 2
lfs f31, 0(r3)
bne- NotElectric
lwz r4, 0xFFFFAEB4(r13)
lfs f0, 0x000001A4(r4)
fmuls f0, f31, f0
stfs f0, 0x00001960(r25)
b StoreForAttacker
NotElectric:
stfs f31, 0x00001960(r25)
StoreForAttacker:
stfs f31, 0x00001960(r12)
lis r12, 0x8007ab0c @h
ori r12, r12, 0x8007ab0c @l
mtctr r12
bctr
OriginalExit:
lwz r0, 0x0000001C(r31)
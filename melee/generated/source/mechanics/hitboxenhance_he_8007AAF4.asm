lwz r4, 0x00000008(r19)
lhz r3, 0(r4)
cmpwi r3, 0x00000004
beq Fighter
cmpwi r3, 0x00000006
bne OriginalExit
Item:
lwz r3, 0x0000002C(r4)
lwz r4, 0x0000000C(r19)
li r5, 1492
li r6, 316
li r7, 4044
lis r8, 0x801510d8 @h
ori r8, r8, 0x801510d8 @l
mtctr r8
bctrl
b CheckValidExtHitStruct
Fighter:
mr r3, r12
lwz r4, 0x0000000C(r19)
li r5, 2324
li r6, 312
li r7, 9196
lis r8, 0x801510d8 @h
ori r8, r8, 0x801510d8 @l
mtctr r8
bctrl
CheckValidExtHitStruct:
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
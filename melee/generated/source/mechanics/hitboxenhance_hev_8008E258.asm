lwz r0, 10680(r29)
cmpwi r0, 0
beq OriginalExit
lwz r0, 0x00000010(r29)
cmpwi r0, 185
beq OriginalExit
cmpwi r0, 193
beq OriginalExit
lwz r3, 0xFFFFAEB4(r13)
lfs f0, 0x00000160(r3)
fcmpo cr0, f30, f0
bge OriginalExit
SetAnimSpeed:
lwz r3, 0x00000028(r24)
lis r12, 0x8000BE40 @h
ori r12, r12, 0x8000BE40 @l
mtctr r12
bctrl
lfs f0, 0xFFFF8B98(rtoc)
fadds f0, f0, f1
lfs f1, 0x00002340(r29)
fcmpo cr0, f0, f1
cror 2, 1, 2
beq OriginalExit
fdivs f1, f0, f1
mr r3, r24
lis r12, 0x8006F190 @h
ori r12, r12, 0x8006F190 @l
mtctr r12
bctrl
OriginalExit:
mr r3, r24
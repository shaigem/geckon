lfs f0, 0xFFFF8870(rtoc)
fcmpo cr0, f1, f0
bge+ OriginalExit
li r3, 0
stw r3, 0x000021D0(r30)
stw r3, 0x000021D8(r30)
lis r12, 0x8006d7e0 @h
ori r12, r12, 0x8006d7e0 @l
mtctr r12
bctr
OriginalExit:
stfs f1, 0x0000195C(r30)
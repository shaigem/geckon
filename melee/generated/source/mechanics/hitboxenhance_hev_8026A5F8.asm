lfs f0, 0xFFFF8870(rtoc)
fcmpo cr0, f1, f0
bge+ OriginalExit
lis r12, 0x8026a68c @h
ori r12, r12, 0x8026a68c @l
mtctr r12
bctrl
OriginalExit:
lfs f0, 0x00000CBC(r31)
lfs f0, 0xFFFF8870(rtoc)
fcmpo cr0, f1, f0
bge+ OriginalExit
lis r12, 0x8008f078 @h
ori r12, r12, 0x8008f078 @l
mtctr r12
bctr
OriginalExit:
stfs f1, 0x0000195C(r27)
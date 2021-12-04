lbz r0, 9336(r30)
rlwimi r0, r3, 0, 1
stb r0, 9336(r30)
stfs f1, 9328(r30)
stfs f1, 0x00001838(r30)
lfs f0, 0xFFFF8870(rtoc)
stfs f0, 9332(r30)
lbz r0, 9340(r30)
rlwimi r0, r3, 0, 1
stb r0, 9340(r30)
lbz r0, 9340(r30)
rlwimi r0, r3, 2, 4
stb r0, 9340(r30)
stfs f1, 9332(r30)
stfs f1, 0x00001838(r30)
lfs f0, 0xFFFF8870(rtoc)
stfs f0, 9336(r30)
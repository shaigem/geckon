lbz r0, 9288(r30)
rlwimi r0, r3, 0, 1
stb r0, 9288(r30)
stfs f1, 9280(r30)
stfs f1, 0x00001838(r30)
lfs f0, 0xFFFF8870(rtoc)
stfs f0, 9284(r30)
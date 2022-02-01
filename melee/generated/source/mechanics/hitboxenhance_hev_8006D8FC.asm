lbz r0, 9440(r30)
rlwimi r0, r3, 0, 1
stb r0, 9440(r30)
lbz r0, 9440(r30)
rlwimi r0, r3, 2, 4
stb r0, 9440(r30)
lbz r0, 9440(r30)
rlwimi r0, r3, 3, 8
stb r0, 9440(r30)
stfs f1, 9432(r30)
lfs f0, 0xFFFF8870(rtoc)
stfs f0, 9436(r30)
Exit:
stfs f1, 0x00001838(r30)
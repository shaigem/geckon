li r3, 0
lbz r0, 10688(r30)
rlwimi r0, r3, 1, 2
stb r0, 10688(r30)
lwz r3, 0x0000010C(r30)
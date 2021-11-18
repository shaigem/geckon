mulli r30, r0, 20
addi r30, r30, 9196
add r30, r31, r30
lfs f0, 0xFFFF8870(rtoc)
stfs f0, 0(r30)
stfs f0, 4(r30)
lfs f0, 0xFFFF8874(rtoc)
stfs f0, 8(r30)
li r3, 0
stw r3, 12(r30)
stw r3, 16(r30)
Exit:
mulli r3, r0, 312
cmpwi r4, 343
beq- OriginalExit
lfs f0, 0xFFFF8870(rtoc)
stfs f0, 0(r3)
stfs f0, 4(r3)
stfs f0, 8(r3)
lfs f0, 0xFFFF8874(rtoc)
stfs f0, 12(r3)
li r0, 0
stw r0, 20(r3)
stw r0, 24(r3)
stw r0, 28(r3)
stw r0, 44(r3)
stw r0, 48(r3)
stw r0, 16(r3)
blr
OriginalExit:
lfs f2, 0xFFFFA4C4(rtoc)
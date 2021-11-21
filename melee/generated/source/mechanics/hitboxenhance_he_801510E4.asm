cmpwi r4, 343
beq- OriginalExit
lfs f0, 0xFFFF8870(rtoc)
stfs f0, 0(r3)
stfs f0, 4(r3)
stfs f0, 8(r3)
lfs f0, 0xFFFF8874(rtoc)
stfs f0, 12(r3)
li r4, 0
stw r4, 16(r3)
stw r4, 20(r3)
blr
OriginalExit:
lfs f2, 0xFFFFA4C4(rtoc)
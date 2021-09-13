lwz r3, 0x00000010(r31)
cmpwi r3, 371
beq Exit
cmpwi r3, 373
beq Exit
Start:
lfs f2, 0x00000018(sp)
lfs f1, 0x000000B4(r31)
lfs f0, 0xFFFFA818(rtoc)
fsubs f1, f2, f1
fcmpo cr0, f1, f0
bge- B8
fneg f0, f1
b BC
B8:
fmr f0, f1
BC:
fcmpo cr0, f0, f31
ble- EC
lfs f0, 0xFFFFA818 (rtoc)
fcmpo cr0, f1, f0
ble- D8
fmr f1, f31
b DC
D8:
fneg f1, f31
DC:
lfs f0, 0x00000084 (r31)
fadds f0, f0, f1
stfs f0, 0x00000084 (r31)
b Exit
EC:
lfs f0, 0x00000084(r31)
fadds f0, f0, f1
stfs f0, 0x00000084(r31)
Exit:
lwz r0, 0x00000034(sp)
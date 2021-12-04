cmpwi r4, 343
beq- OriginalExit
stwu sp, 0xFFFFFFE0(sp)
stw r31, 0x0000001C(sp)
mr r31, r3
lwz r3, 0x0000010C(r3)
lwz r3, 0(r3)
lfs f0, 0x0000005C(r3)
stfs f0, 0x0000016C(r31)
lfs f0, 0x00000060(r3)
stfs f0, 0x00000170(r31)
lwz r0, 0x0000197C(r31)
cmplwi r0, 0
beq Idk1
lwz r3, 0xFFFFAE80(r13)
lfs f1, 0x0000016C(r31)
lfs f0, 0x00000020(r3)
fmuls f0, f1, f0
stfs f0, 0x0000016C(r31)
lfs f1, 0x00000170(r31)
lfs f0, 0x00000024(r3)
fmuls f0, f1, f0
stfs f0, 0x00000170(r31)
Idk1:
lbz r0, 0x00002223(r31)
rlwinm. r0, r0, 0, 31, 31
beq Idk2
lwz r3, 0xFFFFAE7C(r13)
lfs f1, 0x0000016C(r31)
lfs f0, 0x0000000C(r3)
fmuls f0, f1, f0
stfs f0, 0x0000016C(r31)
lfs f1, 0x00000170(r31)
lfs f0, 0x00000010(r3)
fmuls f0, f1, f0
stfs f0, 0x00000170(r31)
Idk2:
lbz r0, 0x00002229(r31)
rlwinm. r0, r0, 26, 31, 31
beq Epilog
lwz r3, 0xFFFFAE78(r13)
lfs f1, 0x0000016C(r31)
lfs f0, 0(r3)
fmuls f0, f1, f0
stfs f0, 0x0000016C(r31)
Epilog:
lwz r31, 0x0000001C(sp)
addi sp, sp, 0x00000020
blr
OriginalExit:
lwz r30, 0x00000004(r5)
cmpwi r4, 343
beq- OriginalExit
mflr r0
stw r0, 0x00000004(sp)
stwu sp, 0xFFFFFFC8(sp)
stw r31, 0x0000001C(sp)
mr r31, r3
lwz r3, 0x0000010C(r3)
lwz r3, 0(r3)
lfs f0, 0x0000005C(r3)
stfs f0, 0x0000016C(r31)
lfs f0, 0x00000060(r3)
stfs f0, 0x00000170(r31)
li r3, 0
lbz r0, 11084(r31)
rlwimi r0, r3, 1, 2
stb r0, 11084(r31)
lfs f0, 0xFFFF9584(rtoc)
lfs f1, 0x00000038(r31)
fcmpu cr0, f0, f1
beq CheckOtherModifiers
addi r4, r31, 0x0000016C
li r3, 0x00000030
bl CalculateForScale
addi r4, r31, 0x00000170
li r3, 0x00000034
bl CalculateForScale
CheckOtherModifiers:
BunnyHoodCheck:
lwz r0, 0x0000197C(r31)
cmplwi r0, 0
beq MetalBoxCheck
lwz r3, 0xFFFFAE80(r13)
lfs f1, 0x0000016C(r31)
lfs f0, 0x00000020(r3)
fmuls f0, f1, f0
stfs f0, 0x0000016C(r31)
lfs f1, 0x00000170(r31)
lfs f0, 0x00000024(r3)
fmuls f0, f1, f0
stfs f0, 0x00000170(r31)
MetalBoxCheck:
lbz r0, 0x00002223(r31)
rlwinm. r0, r0, 0, 31, 31
beq LowGravityCheck
lwz r3, 0xFFFFAE7C(r13)
lfs f1, 0x0000016C(r31)
lfs f0, 0x0000000C(r3)
fmuls f0, f1, f0
stfs f0, 0x0000016C(r31)
lfs f1, 0x00000170(r31)
lfs f0, 0x00000010(r3)
fmuls f0, f1, f0
stfs f0, 0x00000170(r31)
LowGravityCheck:
lbz r0, 0x00002229(r31)
rlwinm. r0, r0, 26, 31, 31
beq Epilog
lwz r3, 0xFFFFAE78(r13)
lfs f1, 0x0000016C(r31)
lfs f0, 0(r3)
fmuls f0, f1, f0
stfs f0, 0x0000016C(r31)
Epilog:
lwz r0, 0x0000003C(sp)
lwz r31, 0x0000001C(sp)
addi sp, sp, 0x00000038
mtlr r0
blr
CalculateForScale:
lwz r0, 0xFFFFAE84(r13)
lfsx f1, r3, r0
lfs f2, 0x00000038(r31)
lfs f3, 0(r4)
lbl_800CFBF0:
lfs f0, 0xFFFF9580(rtoc)
fcmpu cr0, f0, f1
bne lbl_800CFC00
b lbl_800CFC58
lbl_800CFC00:
fcmpo cr0, f1, f0
bge lbl_800CFC20
CallUnkFunc:
mflr r0
stw r0, 0x00000018(sp)
stfd f3, 0x00000030(sp)
fneg f3, f1
lfs f1, 0xFFFF9584(rtoc)
lis r12, 0x800CF594 @h
ori r12, r12, 0x800CF594 @l
mtctr r12
bctrl
lfd f3, 0x00000030(sp)
fdivs f3, f3, f1
lwz r0, 0x00000018(sp)
mtlr r0
b lbl_800CFC58
lbl_800CFC20:
lfs f0, 0xFFFF9584(rtoc)
fcmpo cr0, f2, f0
cror 2, 1, 2
beq lbl_800CFC3C
fcmpo cr0, f1, f0
cror 2, 0, 2
bne lbl_800CFC50
lbl_800CFC3C:
lfs f0, 0xFFFF9584(rtoc)
fsubs f0, f2, f0
fmuls f0, f0, f3
fmadds f3, f1, f0, f3
b lbl_800CFC58
lbl_800CFC50:
fmuls f0, f3, f2
fdivs f3, f0, f1
lbl_800CFC58:
stfs f3, 0(r4)
blr
OriginalExit:
lwz r30, 0x00000004(r5)
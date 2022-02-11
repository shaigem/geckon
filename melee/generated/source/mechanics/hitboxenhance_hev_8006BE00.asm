lwz r3, 10692(r31)
cmplwi r3, 0
beq OriginalExit
VortexKnockback:
mflr r0
stw r0, 0x00000004(r1)
stwu r1, -(56 + 120)(r1)
stmw r20, 0x00000008(r1)
lwz r0, 0x000018AC(r31)
cmpwi r0, 5
lfs f1, 0x0000008C(r31)
lfs f2, 0x00000090(r31)
bge NoMoreTime
bl DataBob
mflr r5
lwz r0, 0(r3)
cmpwi r0, 0
addi r4, r31, 10696
beq Bob
Bob:
mr r3, r28
lfs f1, 0x00000008(r5)
lfs f2, 0x0000000C(r5)
bl ToPointFunc
bl CalcAttackerMomentum
b Epilog
CalcAttackerMomentum:
lwz r4, 0x00001868(r31)
lwz r4, 0x0000002C(r4)
lfs f3, 0x00000084(r4)
lfs f0, 0x000000B4(r4)
fadds f0, f0, f3
lfs f3, 0x000000B4(r4)
fsubs f0, f0, f3
fadds f2, f0, f2
lfs f3, 0x00000080(r4)
lfs f0, 0x000000B0(r4)
fadds f0, f0, f3
lfs f3, 0x000000B0(r4)
fsubs f0, f0, f3
fadds f1, f0, f1
stfs f1, 0x0000008C(r31)
stfs f2, 0x00000090(r31)
blr
ToPointFunc:
mflr r0
stw r0, 4(r1)
stwu r1, 0xFFFFFFA8(r1)
stfd f31, 0x00000050(r1)
fmr f31, f2
stfd f30, 0x00000048(r1)
fmr f30, f1
stfd f29, 0x00000040(r1)
stw r31, 0x0000003C(r1)
stw r30, 0x00000038(r1)
addi r5, r1, 0x0000002C
lwz r31, 0x0000002C(r3)
addi r3, r4, 0
addi r4, r31, 0x000000B0
lis r12, 0x8000D4F8 @h
ori r12, r12, 0x8000D4F8 @l
mtctr r12
bctrl
lfs f1, 0x0000002C(r1)
lfs f2, 0x00000030(r1)
lfs f0, 0xFFFFC2A0(rtoc)
fmuls f1, f1, f0
fmuls f2, f2, f0
lwz r0, 0x0000005C(r1)
lfd f31, 0x00000050(r1)
lfd f30, 0x00000048(r1)
lfd f29, 0x00000040(r1)
lwz r31, 0x0000003C(r1)
lwz r30, 0x00000038(r1)
addi r1, r1, 0x00000058
mtlr r0
blr
Data:
blrl
.float 0.2
.float 0.12
.float 0.5
.float 10.0
.float 80.0
DataBob:
blrl
.float 0.48
.float 0.235
.float 0.16
.float 100.0
NoMoreTime:
li r0, 0
stw r0, 10692(r31)
stw r0, 10696(r31)
stw r0, 10700(r31)
stw r0, 10704(r31)
bl CalcAttackerMomentum
lfs f0, 0xFFFFEC44(rtoc)
fcmpo cr0, f2, f0
blt CheckNegative
fmr f2, f0
b SetYVel
CheckNegative:
lfs f0, 0xFFFF89C0(rtoc)
fcmpo cr0, f2, f0
bge SetYVel
fmr f2, f0
SetYVel:
stfs f2, 0x00000090(r31)
lfs f0, 0xFFFFEC44(rtoc)
fcmpo cr0, f1, f0
blt CheckNegativeX
fmr f1, f0
b SetXVel
CheckNegativeX:
lfs f0, 0xFFFFC928(rtoc)
fcmpo cr0, f1, f0
bge SetXVel
fmr f1, f0
SetXVel:
stfs f1, 0x0000008C(r31)
Epilog:
lmw r20, 0x00000008(r1)
lwz r0, (56 + 0x00000004 + 120)(r1)
addi r1, r1, 56 + 120
mtlr r0
OriginalExit:
lwz r12, 0x000021D0(r31)
addi r3, r31, 0x000000B0
addi r4, sp, 0x00000014
addi r5, r31, 0x00000080
fmr f1, f31
bl CheckMovement
lwz r3, 0x00000010(r31)
cmpwi r3, 371
beq Exit
cmpwi r3, 373
beq Exit
addi r3, r31, 0x000000B4
addi r4, sp, 0x00000018
addi r5, r31, 0x00000084
fmr f1, f31
bl CheckMovement
b Exit
CheckMovement:
mflr r0
stw r0, 0x00000004(r1)
stwu r1, -(56 + 120)(r1)
stmw r20, 0x00000008(r1)
stfd f31, 56(sp)
fmr f31, f1
lfs f2, 0(r4)
lfs f1, 0(r3)
lfs f0, 0xFFFFA818(rtoc)
fsubs f1, f2, f1
fcmpo cr0, f1, f0
bge- PosBiggerThanTarget
fneg f0, f1
b CheckPos
PosBiggerThanTarget:
fmr f0, f1
CheckPos:
fcmpo cr0, f0, f31
ble- HandPosLessSpeed
lfs f0, 0xFFFFA818(rtoc)
fcmpo cr0, f1, f0
ble- MoveLeft
fmr f0, f31
b SetAccelVelocSpeed
MoveLeft:
fneg f0, f31
SetAccelVelocSpeed:
stfs f0, 0(r5)
b Epilog
HandPosLessSpeed:
stfs f1, 0(r5)
Epilog:
lfd f31, 56(sp)
lmw r20, 0x00000008(r1)
lwz r0, (56 + 0x00000004 + 120)(r1)
addi r1, r1, 56 + 120
mtlr r0
blr
Exit:
lis r12, 0x8015bff8 @h
ori r12, r12, 0x8015bff8 @l
mtctr r12
bctr
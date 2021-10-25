cmpwi r4, 343
beq OriginalExit
mflr r0
stw r0, 0x00000004(r1)
stwu r1, -(56 + 120)(r1)
stmw r20, 0x00000008(r1)
mr r29, r3
lwz r31, 0x0000002C(r3)
li r3, 0x0000001C
lis r12, 0x8015C3E8 @h
ori r12, r12, 0x8015C3E8 @l
mtctr r12
bctrl
mr r30, r3
stw r30, 0x00001A5C(r31)
lis r12, 0x8015C31C @h
ori r12, r12, 0x8015C31C @l
mtctr r12
bctrl
cmpwi r3, 0
bne SetupForMasterHand
SetupForCrazyHand:
li r3, 0x0000001B
lis r12, 0x8015C3E8 @h
ori r12, r12, 0x8015C3E8 @l
mtctr r12
bctrl
lwz r4, 0x0000002C(r30)
stw r3, 0x00001A5C(r30)
mr r3, r30
li r4, 380
li r5, 0x00000100
bl TagTsukamuOnGrabSelf
mflr r6
lis r7, 0x8015b548 @h
ori r7, r7, 0x8015b548 @l
lfs f1, 0xFFFFA70C(rtoc)
lfs f2, 0xFFFFA708(rtoc)
bl SetupActionStateAndGrab
SetupForMasterHand:
mr r3, r29
li r4, 385
li r5, 0x00000080
bl TagTsukamuOnGrabSelf
mflr r6
lis r7, 0x80155A58 @h
ori r7, r7, 0x80155A58 @l
lfs f1, 0xFFFFA638(rtoc)
lfs f2, 0xFFFFA63C(rtoc)
bl SetupActionStateAndGrab
EndFunction:
lmw r20, 0x00000008(r1)
lwz r0, (56 + 0x00000004 + 120)(r1)
addi r1, r1, 56 + 120
mtlr r0
blr
SetupActionStateAndGrab:
mflr r0
stw r0, 0x00000004(r1)
stwu r1, -(56 + 120)(r1)
stmw r20, 0x00000008(r1)
lwz r31, 0x0000002C(r3)
mr r30, r3
mr r29, r5
mr r28, r6
mr r27, r7
li r5, 0
li r6, 0
fmr f3, f1
lis r12, 0x800693AC @h
ori r12, r12, 0x800693AC @l
mtctr r12
bctrl
mr r3, r30
lis r12, 0x8006EBA4 @h
ori r12, r12, 0x8006EBA4 @l
mtctr r12
bctrl
mr r5, r28
mr r7, r27
mr r3, r31
mr r4, r29
li r6, 0
lis r12, 0x8007E2D0 @h
ori r12, r12, 0x8007E2D0 @l
mtctr r12
bctrl
li r0, 0
stw r0, 0x00002360(r31)
lmw r20, 0x00000008(r1)
lwz r0, (56 + 0x00000004 + 120)(r1)
addi r1, r1, 56 + 120
mtlr r0
blr
TagTsukamuOnGrabSelf:
blrl
mflr r0
stw r0, 0x00000004(r1)
stwu r1, -(56 + 120)(r1)
stmw r20, 0x00000008(r1)
mr r31, r3
lwz r30, 0x0000002C(r3)
li r4, 0
li r0, 1
lfs f0, 0xFFFFA5EC(rtoc)
stfs f0, 0x00000088(r30)
stfs f0, 0x00000084(r30)
stfs f0, 0x00000080(r30)
stw r0, 0x00002360(r30)
lbz r0, 0x0000221E(r30)
rlwimi r0, r4, 1, 30, 30
stb r0, 0x0000221E(r30)
lwz r3, 0x00001A58(r30)
li r4, 537
li r5, 5
li r6, 0
li r7, 0
addi r8, sp, 56
addi r9, sp, 56 + 0x0000000C
li r0, 0
stw r0, 0x00000000(r8)
stw r0, 0x00000004(r8)
stw r0, 0x00000008(r8)
li r0, 0
stw r0, 0x00000000(r9)
stw r0, 0x00000004(r9)
stw r0, 0x00000008(r9)
lis r12, 0x8009f834 @h
ori r12, r12, 0x8009f834 @l
mtctr r12
bctrl
mr r3, r30
lis r4, 0x00000005
subi r4, r4, 7663
li r5, 127
li r6, 64
lis r12, 0x80088148 @h
ori r12, r12, 0x80088148 @l
mtctr r12
bctrl
lmw r20, 0x00000008(r1)
lwz r0, (56 + 0x00000004 + 120)(r1)
addi r1, r1, 56 + 120
mtlr r0
blr
OriginalExit:
stw r0, 0x00000004(sp)
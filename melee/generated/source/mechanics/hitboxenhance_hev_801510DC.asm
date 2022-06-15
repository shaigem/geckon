cmpwi r4, 343
beq- OriginalExit
cmplwi r3, 0
beq EpilogReturn
mflr r0
stw r0, 0x00000004(r1)
stwu r1, -(56 + 120)(r1)
stmw r20, 0x00000008(r1)
lwz r31, 0x0000002C(r3)
lwz r30, 0x0000002C(r4)
mr r29, r5
mr r27, r3
mr r26, r4
cmplwi r6, 0
mr r28, r6
bne CalculateTypes
CalculateExtHitOffset:
mr r3, r27
mr r4, r29
lis r12, 0x801510d4 @h
ori r12, r12, 0x801510d4 @l
mtctr r12
bctrl
cmplwi r3, 0
beq Epilog
mr r28, r3
CalculateTypes:
mr r3, r27
bl IsItemOrFighter
cmplwi r3, 0
beq Epilog
mr r25, r3
mr r3, r26
bl IsItemOrFighter
cmplwi r3, 0
beq Epilog
mr r24, r3
StoreHitlag:
lbz r0, 16(r28)
rlwinm. r5, r0, 0, 16
beq StoreHitlagChecks
li r5, 1
StoreHitlagChecks:
lfs f0, 0(r28)
cmpwi r25, 1
addi r3, r31, 5824
bne StoreHitlagMultiForAttacker
addi r3, r31, 0x00001960
lbz r0, 11084(r31)
rlwimi r0, r5, 5, 32
stb r0, 11084(r31)
StoreHitlagMultiForAttacker:
stfs f0, 0(r3)
cmpwi r24, 1
addi r3, r30, 5824
bne ElectricHitlagCalculate
addi r3, r30, 0x00001960
lbz r0, 11084(r30)
rlwimi r0, r5, 5, 32
stb r0, 11084(r30)
ElectricHitlagCalculate:
lwz r0, 0x00000030(r29)
cmplwi r0, 2
bne+ StoreHitlagMultiForDefender
lwz r4, 0xFFFFAEB4(r13)
lfs f1, 0x000001A4(r4)
fmuls f0, f1, f0
StoreHitlagMultiForDefender:
stfs f0, 0(r3)
cmpwi r24, 1
bne Epilog
StoreHitstunModifier:
lfs f0, 12(r28)
stfs f0, 11076(r30)
StoreSDIMultiplier:
lfs f0, 4(r28)
stfs f0, 11072(r30)
CalculateFlippyDirection:
lbz r3, 16(r28)
lfs f0, 0x0000002C(r31)
rlwinm. r0, r3, 0, 26, 26
bne FlippyForward
rlwinm. r0, r3, 0, 25, 25
bne StoreCalculatedDirection
b SetWeight
FlippyForward:
fneg f0, f0
StoreCalculatedDirection:
stfs f0, 0x00001844(r30)
SetWeight:
lbz r3, 16(r28)
rlwinm. r3, r3, 0, 128
beq ResetTempGravityFallSpeed
SetTempGravityFallSpeed:
bl Constants
mflr r3
addi r4, r30, 0x00000110
lfs f0, 0(r3)
stfs f0, 0x0000005C(r4)
lfs f0, 4(r3)
stfs f0, 0x00000060(r4)
li r3, 1
lbz r0, 11084(r30)
rlwimi r0, r3, 1, 2
stb r0, 11084(r30)
b StoreDisableMeteorCancel
ResetTempGravityFallSpeed:
lbz r3, 11084(r30)
rlwinm. r3, r3, 0, 2
beq StoreDisableMeteorCancel
mr r3, r30
lis r12, 0x801510e8 @h
ori r12, r12, 0x801510e8 @l
mtctr r12
bctrl
StoreDisableMeteorCancel:
lbz r3, 16(r28)
rlwinm. r0, r3, 0, 4
li r3, 0
beq MeteorCancelSet
li r3, 1
MeteorCancelSet:
lbz r0, 11084(r30)
rlwimi r0, r3, 2, 4
stb r0, 11084(r30)
Epilog:
lmw r20, 0x00000008(r1)
lwz r0, (56 + 0x00000004 + 120)(r1)
addi r1, r1, 56 + 120
mtlr r0
EpilogReturn:
blr
IsItemOrFighter:
lhz r0, 0(r3)
cmplwi r0, 0x00000004
li r3, 1
beq Result
li r3, 2
cmplwi r0, 0x00000006
beq Result
li r3, 0
Result:
blr
Constants:
blrl
.float 0.095
.float 1.7
OriginalExit:
lwz r5, 0x0000010C(r31)
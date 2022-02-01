lbz r3, 10688(r29)
rlwinm. r3, r3, 0, 1
beq UnhandledExit
lbz r0, 0x00002222(r29)
rlwinm. r0, r0, 27, 31, 31
beq lbl_800C355C
b HandledExit
lbl_800C355C:
lbz r0, 0x00002071(r29)
rlwinm r0, r0, 28, 28, 31
cmpwi r0, 12
bge HandleWindbox
cmpwi r0, 10
beq HandleWindbox
cmpwi r0, 9
bge HandledExit
b HandleWindbox
HandleWindbox:
mr r3, r31
bl Damage_Windbox
HandledExit:
lis r12, 0x8008f71c @h
ori r12, r12, 0x8008f71c @l
mtctr r12
bctr
Damage_Windbox:
mflr r0
stw r0, 0x00000004 (sp)
lis r0, 0x00004330
stwu sp, 0xFFFFFFC0 (sp)
stfd f31, 0x00000038 (sp)
stfd f30, 0x00000030 (sp)
stfd f29, 0x00000028 (sp)
stw r31, 0x00000024 (sp)
lwz r5, 0x0000002C (r3)
mr r31, r5
lbl_800C3634:
lwz r3, 0xFFFFAEB4(r13)
lfs f0, 0x00000100(r3)
lfs f1, 0x00001850(r31)
fmuls f31, f1, f0
CheckAttackAngle:
mr r3, r31
lfs f1, 0x00001850(r31)
lis r12, 0x8008D7F0 @h
ori r12, r12, 0x8008D7F0 @l
mtctr r12
bctrl
fmr f30, f1
lis r12, 0x80326240 @h
ori r12, r12, 0x80326240 @l
mtctr r12
bctrl
fmuls f29, f31, f1
fmr f1, f30
lis r12, 0x803263D4 @h
ori r12, r12, 0x803263D4 @l
mtctr r12
bctrl
lwz r0, 0x000000E0 (r31)
fmuls f2, f31, f1
cmpwi r0, 1
bne StoreVelocityGrounded
lfs f0, 0x00001844(r31)
mr r3, r31
fneg f1, f29
fmuls f1, f1, f0
lis r12, 0x8008DC0C @h
ori r12, r12, 0x8008DC0C @l
mtctr r12
bctrl
lfs f0, 0xFFFF92F8(rtoc)
stfs f0, 0x000000F0(r31)
b StoreSlotLastDamaged
StoreVelocityGrounded:
fneg f1, f29
lfs f0, 0x00001844(r31)
fmuls f0, f1, f0
fmr f1, f0
stfs f1, 0x000000F0(r31)
mr r3, r31
lfs f0, 0x00000844(r31)
fneg f0, f0
fmuls f2, f0, f1
lis r12, 0x8008DC0C @h
ori r12, r12, 0x8008DC0C @l
mtctr r12
bctrl
StoreSlotLastDamaged:
li r3, 0
stw r3, 0x000018AC(r31)
lwz r0, 0x00000044 (sp)
lfd f31, 0x00000038 (sp)
lfd f30, 0x00000030 (sp)
lfd f29, 0x00000028 (sp)
lwz r31, 0x00000024 (sp)
addi sp, sp, 64
mtlr r0
blr
UnhandledExit:
mr r3, r31
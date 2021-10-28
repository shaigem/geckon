mflr r0
stw r0, 0x00000004(r1)
stwu r1, -(56 + 120)(r1)
stmw r20, 0x00000008(r1)
mr r29, r3
lwz r31, 0x0000002C(r3)
lis r12, 0x80085134 @h
ori r12, r12, 0x80085134 @l
mtctr r12
bctrl
lis r4, 2
stw r4, 56(sp)
psq_l f1, 56(sp), 1, 5
lfs f2, 0xFFFFA4AC(rtoc)
lfs f0, 0x00000620(r31)
fcmpo cr0, f2, f1
beq SetVelY
fmuls f0, f0, f1
lfs f1, 0x00000080(r31)
fadds f0, f1, f0
stfs f0, 0x00000080(r31)
SetVelY:
lfs f0, 0x00000624(r31)
fcmpo cr0, f2, f0
beq Exit
psq_l f1, 56(sp), 1, 5
fmuls f0, f0, f1
lfs f1, 0x00000084(r31)
fadds f0, f1, f0
stfs f0, 0x00000084(r31)
Exit:
mr r3, r29
lmw r20, 0x00000008(r1)
lwz r0, (56 + 0x00000004 + 120)(r1)
addi r1, r1, 56 + 120
mtlr r0
lis r12, 0x8015088c @h
ori r12, r12, 0x8015088c @l
mtctr r12
bctr
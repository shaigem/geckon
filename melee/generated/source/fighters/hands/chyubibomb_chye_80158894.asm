mflr r0
stw r0, 0x00000004(r1)
stwu r1, -(56 + 120)(r1)
stmw r20, 0x00000008(r1)
mr r29, r3
lwz r31, 0x0000002C(r3)
lwz r4, 0x0000010C(r31)
lwz r30, 0x00000004(r4)
lis r12, 0x80085134 @h
ori r12, r12, 0x80085134 @l
mtctr r12
bctrl
lfs f1, 0x00002340(r31)
lfs f0, 0xFFFFA6B4(rtoc)
fadds f1, f1, f0
stfs f1, 0x00002340(r31)
bl Constants
mflr r3
lfs f0, 0x00000000(r3)
fcmpo cr0, f1, f0
ble- Exit
lfs f1, 0x00002340(r31)
lfs f0, 0x00000004(r3)
fcmpo cr0, f1, f0
bge- Exit
lfs f1, 0x00000008(r3)
mr r3, r29
lis r12, 0x8015C010 @h
ori r12, r12, 0x8015C010 @l
mtctr r12
bctrl
Exit:
mr r3, r29
lmw r20, 0x00000008(r1)
lwz r0, (56 + 0x00000004 + 120)(r1)
addi r1, r1, 56 + 120
mtlr r0
lis r12, 0x801588B0 @h
ori r12, r12, 0x801588B0 @l
mtctr r12
bctr
Constants:
blrl
.float 60.0
.float 230.0
.float 0.3
.align 2
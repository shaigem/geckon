mflr r0
stw r0, 0x00000004(r1)
stwu r1, -(56 + 120)(r1)
stmw r20, 0x00000008(r1)
lbz r3, 0x0000000C(r3)
cmpwi r3, 0
bne Exit
addi r3, sp, 0x00000080
li r4, 0
stw r4, 0(r3)
stw r4, 0x00000004(r3)
li r4, 12
stw r4, 0x00000008(r3)
lfs f31, 0xFFFFD7A8(rtoc)
lfs f30, 0x000000B0(r31)
lfs f29, 0x000000B4(r31)
stfs f30, 0x00000014(r3)
stfs f29, 0x00000018(r3)
stfs f31, 0x0000001C(r3)
stfs f30, 0x00000020(r3)
stfs f29, 0x00000024(r3)
stfs f31, 0x00000028(r3)
stfs f31, 0x0000002C(r3)
stfs f31, 0x00000030(r3)
stfs f31, 0x00000034(r3)
stfs f31, 0x00000038(r3)
li r4, 0
sth r4, 0x0000003C(r3)
lis r12, 0x80268B18 @h
ori r12, r12, 0x80268B18 @l
mtctr r12
bctrl
lwz r3, 0x0000002C(r3)
lwz r4, 0x00000004(r3)
mr r3, r31
lis r12, 0x800948a8 @h
ori r12, r12, 0x800948a8 @l
mtctr r12
bctrl
Exit:
lmw r20, 0x00000008(r1)
lwz r0, (56 + 0x00000004 + 120)(r1)
addi r1, r1, 56 + 120
mtlr r0
mr r3, r31
lwz r0, 0x0000004C(sp)
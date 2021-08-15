mflr r0
stw r0, 0x00000004(r1)
stwu r1, -(0x00000038 + 0x00000078)(r1)
stmw r20, 0x00000008(r1)
mr r31, r0
mr r30, r4
mr r29, r5
li r3, 363
lis r12, 0x80380580 @h
ori r12, r12, 0x80380580 @l
mtctr r12
bctrl
mr r0, r31
mr r4, r30
mr r5, r29
lmw r20, 0x00000008(r1)
lwz r0, (0x00000038 + 0x00000004 + 0x00000078)(r1)
addi r1, r1, 0x00000038 + 0x00000078
mtlr r0
stw r3, 0x00000020(r29)
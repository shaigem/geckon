mflr r0
stw r0, 0x00000004(r1)
stwu r1, -(56 + 120)(r1)
stmw r20, 0x00000008(r1)
mr r31, r0
mr r30, r3
mr r29, r5
li r3, 363
lis r12, 0x80380580 @h
ori r12, r12, 0x80380580 @l
mtctr r12
bctrl
mr r4, r3
mr r0, r31
mr r3, r30
mr r5, r29
lmw r20, 0x00000008(r1)
lwz r0, (56 + 0x00000004 + 120)(r1)
addi r1, r1, 56 + 120
mtlr r0
cmplwi r4, 361
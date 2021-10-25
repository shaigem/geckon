mflr r0
stw r0, 0x00000004(r1)
stwu r1, -(56 + 120)(r1)
stmw r20, 0x00000008(r1)
mr r31, r3
lis r12, 0x800822a4 @h
ori r12, r12, 0x800822a4 @l
mtctr r12
bctrl
cmpwi r3, 0
beq Exit
li r3, 99
Exit:
lmw r20, 0x00000008(r1)
lwz r0, (56 + 0x00000004 + 120)(r1)
addi r1, r1, 56 + 120
mtlr r0
blr
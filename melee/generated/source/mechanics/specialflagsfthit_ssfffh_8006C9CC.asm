mr r3, r29
ResetAllHitPlayers:
mflr r0
stw r0, 0x00000004(r1)
stwu r1, -(56 + 120)(r1)
stmw r20, 0x00000008(r1)
li r30, 0
mulli r0, r30, 312
lwz r3, 0x0000002C(r3)
add r31, r3, r0
Loop:
addi r3, r31, 2324
lis r12, 0x80008a5c @h
ori r12, r12, 0x80008a5c @l
mtctr r12
bctrl
addi r30, r30, 1
cmplwi r30, 4
addi r31, r31, 312
blt+ Loop
lmw r20, 0x00000008(r1)
lwz r0, (56 + 0x00000004 + 120)(r1)
addi r1, r1, 56 + 120
mtlr r0
Exit:
mr r3, r29
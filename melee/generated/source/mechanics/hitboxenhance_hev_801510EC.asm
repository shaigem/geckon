cmpwi r4, 343
beq- OriginalExit
mflr r0
stw r0, 0x00000004(sp)
stwu sp, 0xFFFFFFD0(sp)
stw r31, 0x0000002C(sp)
stw r30, 0x00000028(sp)
mr r31, r4
mr r30, r3
lis r12, 0x801510d4 @h
ori r12, r12, 0x801510d4 @l
mtctr r12
bctrl
cmplwi r3, 0
beq Exit
lbz r3, 16(r3)
rlwinm. r3, r3, 0, 27, 27
beq Exit
lhz r0, 0(r30)
cmplwi r0, 0x00000004
beq SetForFighter
cmplwi r0, 0x00000006
bne GetInitialPos
mr r3, r30
lis r12, 0x80275788 @h
ori r12, r12, 0x80275788 @l
mtctr r12
bctrl
b GetInitialPos
SetForFighter:
li r0, 2
stw r0, 0(r31)
GetInitialPos:
lwz r3, 0x00000048(r31)
li r4, 0
addi r5, sp, 0x0000000C
lis r12, 0x8000B1CC @h
ori r12, r12, 0x8000B1CC @l
mtctr r12
bctrl
lwz r3, 0x00000010(r31)
lwz r4, 0x00000014(r31)
stw r3, 0x00000018(sp)
stw r4, 0x0000001C(sp)
lwz r4, 0x00000018(r31)
stw r4, 0x00000020(sp)
lwz r3, 0x00000048(r31)
addi r4, sp, 0x00000018
addi r5, sp, 0x00000018
lis r12, 0x8000B1CC @h
ori r12, r12, 0x8000B1CC @l
mtctr r12
bctrl
addi r4, sp, 0x0000000C
addi r5, sp, 0x00000018
mr r6, r31
lis r12, 0x80275830 @h
ori r12, r12, 0x80275830 @l
mtctr r12
bctrl
Exit:
lwz r0, 0x00000034(sp)
lwz r31, 0x0000002C(sp)
lwz r30, 0x00000028(sp)
addi sp, sp, 0x00000030
mtlr r0
blr
OriginalExit:
li r5, 0
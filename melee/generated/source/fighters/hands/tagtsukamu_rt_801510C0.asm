cmpwi r4, 343
beq OriginalExit
mflr r0
stw r0, 0x00000004(r1)
stwu r1, -(56 + 120)(r1)
stmw r20, 0x00000008(r1)
mr r29, r3
lwz r31, 0x0000002C(r3)
lwz r6, 0x0000010C(r31)
lwz r30, 0x00000004(r6)
lwz r4, 0x00000004(r31)
cmpwi r4, 0x0000001B
bne SetupChVars
SetupMhVars:
addi r28, r30, 0x00000118
addi r27, r30, 0x0000011C
subi r26, rtoc, 0x00005A00
lis r25, 0x80155B80 @h
ori r25, r25, 0x80155B80 @l
li r4, 386
lfs f1, 0xFFFFA600(rtoc)
lfs f2, 0xFFFFA604(rtoc)
fmr f3, f1
b ChangeActionState
SetupChVars:
addi r28, r30, 0x000000D0
addi r27, r30, 0x000000D4
subi r26, rtoc, 0x000058E0
lis r25, 0x8015B670 @h
ori r25, r25, 0x8015B670 @l
li r4, 381
lfs f1, 0xFFFFA720(rtoc)
lfs f2, 0xFFFFA724(rtoc)
fmr f3, f1
ChangeActionState:
li r0, 0
li r5, 0
li r6, 0
lis r12, 0x800693AC @h
ori r12, r12, 0x800693AC @l
mtctr r12
bctrl
mr r3, r29
lis r12, 0x8006EBA4 @h
ori r12, r12, 0x8006EBA4 @l
mtctr r12
bctrl
lbz r0, 0x00002222(r31)
li r3, 1
rlwimi r0, r3, 5, 26, 26
stb r0, 0x00002222(r31)
mr r3, r31
li r4, 511
lis r12, 0x8007E2F4 @h
ori r12, r12, 0x8007E2F4 @l
mtctr r12
bctrl
mr r3, r29
lis r12, 0x8007E2FC @h
ori r12, r12, 0x8007E2FC @l
mtctr r12
bctrl
lwz r3, 0x00001A58(r31)
mtctr r25
bctrl
lfs f0, 0(r28)
stfs f0, 0x0000234C(r31)
lfs f0, 0(r27)
stfs f0, 0x00002350(r31)
lfs f0, 0(r26)
stfs f0, 0x00002354(r31)
lmw r20, 0x00000008(r1)
lwz r0, (56 + 0x00000004 + 120)(r1)
addi r1, r1, 56 + 120
mtlr r0
blr
OriginalExit:
stwu sp, 0xFFFFFFE0(sp)
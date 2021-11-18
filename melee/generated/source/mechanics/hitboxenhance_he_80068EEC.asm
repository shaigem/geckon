NonVanilla20XX:
li r4, 0
stw r4, 0x00000020(r31)
stw r4, 0x00000024(r31)
stb r4, 0x0000000D(r3)
sth r4, 0x0000000E(r3)
stb r4, 0x000021FD(r3)
sth r4, 0x000021FE(r3)
addi r30, r3, 0
lis r4, 0x80458fd0 @h
ori r4, r4, 0x80458fd0 @l
lwz r4, 0x00000020(r4)
lis r12, 0x8000c160 @h
ori r12, r12, 0x8000c160 @l
mtctr r12
bctrl
Exit:
mr r3, r30
lis r4, 0x00008046
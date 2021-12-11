.include "punkpc.s"
punkpc ppc

gecko 2147913452
li r4, 0
stw r4, 32(r31)
stw r4, 36(r31)
stb r4, 13(r3)
sth r4, 14(r3)
stb r4, 8701(r3)
sth r4, 8702(r3)
addi r30, r3, 0
load r4, 2152042448
lwz r4, 32(r4)
bla r12, 2147533152
mr r3, r30
lis r4, 32838
gecko 2147908028, li r4, 9292
gecko 2148754716, blr
gecko.end
gecko 2150002648, li r4, 4128
gecko 2150008660
addi r29, r3, 0
li r4, 4128
bla r12, 2147533152
mr r3, r29
mr. r6, r3
gecko.end
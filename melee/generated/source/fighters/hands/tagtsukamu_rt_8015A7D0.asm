lwz r31, 0x0000002C(r30)
lwz r0, 0x00002200(r31)
cmplwi r0, 0
beq Exit
li r0, 0
stw r0, 0x00002200(r31)
li r4, 339
lwz r3, 0x00001A58(r31)
lis r12, 0x8015B850 @h
ori r12, r12, 0x8015B850 @l
mtctr r12
bctrl
lwz r3, 0x00001A58(r31)
cmplwi r3, 0
beq Exit
mr r31, r3
lwz r3, 0x0000002C(r30)
li r4, 0
lis r12, 0x8007E2F4 @h
ori r12, r12, 0x8007E2F4 @l
mtctr r12
bctrl
mr r3, r30
mr r4, r31
lis r12, 0x800DE2A8 @h
ori r12, r12, 0x800DE2A8 @l
mtctr r12
bctrl
mr r3, r31
lwz r4, 0x0000002C(r3)
lfs f1, 0x00001844(r4)
lfs f0, 0xFFFFA730(rtoc)
fmuls f0, f1, f0
stfs f0, 0x00001844(r4)
li r4, 0
li r5, 0
lis r12, 0x800DE7C0 @h
ori r12, r12, 0x800DE7C0 @l
mtctr r12
bctrl
Exit:
mr r3, r30
lis r12, 0x8015c358 @h
ori r12, r12, 0x8015c358 @l
mtctr r12
bctrl
cmpwi r3, 0x0000017C
beq Setup
bge OriginalExit
Setup:
lfs f1, 0x0000013C(r29)
lis r4, 0x801510b8 @h
ori r4, r4, 0x801510b8 @l
lfs f0, 0xFFFFA4AC(rtoc)
stfs f1, 0x0000002C(sp)
mr r3, r28
lfs f1, 0x00000140(r29)
addi r5, sp, 0x0000002C
stfs f1, 0x00000030(sp)
stfs f0, 0x00000034(sp)
lis r12, 0x80150460 @h
ori r12, r12, 0x80150460 @l
mtctr r12
bctr
OriginalExit:
cmpwi r3, 381
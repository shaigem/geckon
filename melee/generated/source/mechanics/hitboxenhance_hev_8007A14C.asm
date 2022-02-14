lwz r3, 0(r15)
mr r4, r17
lis r12, 0x801510d4 @h
ori r12, r12, 0x801510d4 @l
mtctr r12
bctrl
cmplwi r3, 0
lfs f4, 0x00000088(r27)
beq Exit
mr r18, r3
stw r3, 0x00000090(sp)
StoreWindboxFlag:
lbz r4, 16(r18)
rlwinm. r4, r4, 0, 8
li r3, 0
beq WindboxSet
li r3, 1
WindboxSet:
lbz r4, 11084(r25)
rlwimi r4, r3, 0, 1
stb r4, 11084(r25)
lbz r4, 16(r18)
rlwinm. r4, r4, 0, 128
beq Exit
UseSetWeight:
lwz r3, 0xFFFFAEB4(r13)
lfs f4, 0x0000010C(r3)
Exit:
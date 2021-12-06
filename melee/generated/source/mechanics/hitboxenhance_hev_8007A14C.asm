lwz r3, 0(r15)
lwz r4, 0(r25)
mr r5, r17
lis r12, 0x801510d4 @h
ori r12, r12, 0x801510d4 @l
mtctr r12
bctrl
cmplwi r3, 0
lfs f4, 0x00000088(r27)
beq Exit
lbz r4, 16(r3)
rlwinm. r4, r4, 0, 24, 24
beq NoSetWeight
UseSetWeight:
lwz r3, 0xFFFFAEB4(r13)
lfs f4, 0x0000010C(r3)
bl Constants
mflr r3
lfs f0, 0(r3)
stfs f0, 0x0000005C(r27)
lfs f0, 4(r3)
stfs f0, 0x00000060(r27)
li r3, 1
lbz r0, 9288(r25)
rlwimi r0, r3, 1, 2
stb r0, 9288(r25)
b Exit
NoSetWeight:
lbz r3, 9288(r25)
rlwinm. r3, r3, 0, 2
beq Exit
li r3, 0
lbz r0, 9288(r25)
rlwimi r0, r3, 1, 2
stb r0, 9288(r25)
fmr f3, f1
mr r3, r25
lis r12, 0x801510e8 @h
ori r12, r12, 0x801510e8 @l
mtctr r12
bctrl
fmr f1, f3
b Exit
Constants:
blrl
.float 0.095
.float 1.7
Exit:
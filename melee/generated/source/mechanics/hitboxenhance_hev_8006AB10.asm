lwz r3, 0x000018AC(r31)
cmpwi r3, 10
blt Exit
lbz r0, 9340(r31)
rlwinm. r0, r0, 0, 2
beq Exit
mr r3, r31
lis r12, 0x801510e8 @h
ori r12, r12, 0x801510e8 @l
mtctr r12
bctrl
li r3, 0
lbz r0, 9340(r31)
rlwimi r0, r3, 1, 2
stb r0, 9340(r31)
lwz r3, 0x000018AC(r31)
Exit:
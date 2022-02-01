lwz r3, 0x000018AC(r31)
cmpwi r3, 10
blt Exit
lbz r0, 10688(r31)
rlwinm. r0, r0, 0, 2
beq Exit
mr r3, r31
lis r12, 0x801510e8 @h
ori r12, r12, 0x801510e8 @l
mtctr r12
bctrl
lwz r3, 0x000018AC(r31)
Exit:
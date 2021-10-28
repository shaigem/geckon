cmpwi r3, 3
bne Exit
li r3, 2
lis r12, 0x80380580 @h
ori r12, r12, 0x80380580 @l
mtctr r12
bctrl
cmpwi r3, 0
bne Exit
li r3, 0x0000017C
lis r12, 0x8015664c @h
ori r12, r12, 0x8015664c @l
mtctr r12
bctr
Exit:
lbz r0, 0(r26)
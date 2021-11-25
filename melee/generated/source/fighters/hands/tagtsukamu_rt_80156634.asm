cmpwi r3, 3
bne Exit
mr r7, r3
li r3, 2
lis r12, 0x80380580 @h
ori r12, r12, 0x80380580 @l
mtctr r12
bctrl
cmpwi r3, 0
bne RestoreOldValue
TagTsukamu:
li r3, 0x0000017C
lis r12, 0x8015664c @h
ori r12, r12, 0x8015664c @l
mtctr r12
bctr
RestoreOldValue:
mr r3, r7
Exit:
lbz r0, 0(r26)
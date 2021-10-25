lfs f1, 0xFFFFA5EC(rtoc)
lwz r5, 0x00000010(r31)
cmpwi r5, 386
bne Exit
li r4, 388
Exit:
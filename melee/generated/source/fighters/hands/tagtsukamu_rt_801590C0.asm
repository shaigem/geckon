lfs f1, 0xFFFFA70C(rtoc)
lwz r5, 0x00000010(r31)
cmpwi r5, 381
bne Exit
li r4, 383
Exit:
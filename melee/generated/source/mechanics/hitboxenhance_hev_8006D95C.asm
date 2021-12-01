lwz r3, 0x00001A58(r30)
cmplwi r3, 0
bne Exit
stfs f0, 0x00001960(r30)
Exit:
li r3, 0
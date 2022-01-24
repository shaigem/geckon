lwz r0, 0x00001A58(r30)
cmplwi r0, 0
bne Exit
stfs f0, 0x00001960(r30)
Exit:
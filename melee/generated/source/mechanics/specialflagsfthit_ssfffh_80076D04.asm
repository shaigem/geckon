lbz r4, 0x00000041(r30)
rlwinm. r4, r4, 31, 31, 31
li r4, 1
beq Exit
li r4, 2
Exit:
lbz r4, 0x00000041(r27)
rlwinm. r4, r4, 30, 31, 31
li r4, 0
beq Exit
li r4, 5
Exit:
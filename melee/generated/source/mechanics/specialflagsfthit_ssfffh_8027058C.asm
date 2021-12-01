lbz r5, 0x00000041(r26)
rlwinm. r5, r5, 29, 31, 31
li r5, 0
beq Exit
li r5, 8
Exit:
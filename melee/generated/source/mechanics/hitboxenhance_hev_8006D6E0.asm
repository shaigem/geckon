lbz r0, 11228(r30)
rlwinm. r0, r0, 0, 8
beq OriginalExit
lwz r29, 0x0000183C(r30)
OriginalExit:
mr r3, r30
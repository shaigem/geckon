lwz r3, 0x0000002C(r3)
lbz r0, 11264(r3)
rlwinm. r0, r0, 0, 1
beq OriginalExit
blr
OriginalExit:
lwz r3, 0(r3)
mflr r0
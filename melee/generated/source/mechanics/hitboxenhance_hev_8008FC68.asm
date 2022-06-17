lbz r0, 11228(r31)
rlwinm. r0, r0, 0, 64
beq OriginalExit
lis r12, 0x8008fc74 @h
ori r12, r12, 0x8008fc74 @l
mtctr r12
bctr
OriginalExit:
mr r3, r30
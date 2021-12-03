lbz r0, 0x00000042(r23)
rlwinm. r0, r0, 26, 31, 31
bne OriginalExit
SkipShield:
lis r12, 0x800790B4 @h
ori r12, r12, 0x800790B4 @l
mtctr r12
bctr
OriginalExit:
rlwinm. r0, r3, 28, 31, 31
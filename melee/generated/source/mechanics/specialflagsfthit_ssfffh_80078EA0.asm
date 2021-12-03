lbz r0, 0x00000042(r23)
rlwinm. r0, r0, 27, 31, 31
beq OriginalExit
lfs f1, 0x0000002C(r28)
lfs f0, 0x0000002C(r24)
fcmpu cr0, f1, f0
beq CanHit
b OriginalExit
CanHit:
lis r12, 0x80079228 @h
ori r12, r12, 0x80079228 @l
mtctr r12
bctr
OriginalExit:
lbz r0, 0x00000134(r23)
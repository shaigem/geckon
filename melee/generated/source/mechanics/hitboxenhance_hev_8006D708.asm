lbz r3, 11264(r30)
rlwinm. r3, r3, 0, 32
beq CheckHitlagFrames
li r5, 0
CheckASDIFunction:
lis r0, 0x8008e714 @h
ori r0, r0, 0x8008e714 @l
lwz r3, 0x000021D8(r30)
cmplw r3, r0
bne CheckSDIFunction
stw r5, 0x000021D8(r30)
CheckSDIFunction:
lis r0, 0x8008e4f0 @h
ori r0, r0, 0x8008e4f0 @l
lwz r3, 0x000021D0(r30)
cmplw r3, r0
bne SkipHitlagFunctions
stw r5, 0x000021D0(r30)
SkipHitlagFunctions:
lis r12, 0x8006d7e0 @h
ori r12, r12, 0x8006d7e0 @l
mtctr r12
bctr
CheckHitlagFrames:
lfs f0, 0xFFFF8870(rtoc)
fcmpo cr0, f1, f0
cror 2, 1, 2
beq OriginalExit
fmr f1, f0
OriginalExit:
stfs f1, 0x0000195C(r30)
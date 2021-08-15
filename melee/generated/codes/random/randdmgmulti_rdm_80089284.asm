li r3, 101
lis r12, 0x80380580 @h
ori r12, r12, 0x80380580 @l
mtctr r12
bctrl
addis r3, r3, 10
stw r3, 0x00000014(sp)
psq_l f31, 0x00000014(sp), 0, 5
ps_muls1 f1, f1, f31
ps_div f1, f1, f31
b OriginalExit
OriginalExit:
lwz r0, 0x0000002C(sp)
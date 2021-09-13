lfs f1, 0x00000620(r3)
lfs f0, 0xFFFFA4AC(rtoc)
fcmpo cr0, f1, f0
beq Exit
lis r12, 0x8007d9fc @h
ori r12, r12, 0x8007d9fc @l
mtctr r12
bctrl
lfd f1, 0xFFFF8890(rtoc)
li r4, 0
fmul f1, f1, f0
frsp f1, f1
lis r12, 0x80075AF0 @h
ori r12, r12, 0x80075AF0 @l
mtctr r12
bctrl
mr r3, r31
Exit:
lbz r3, 0x0000000C(r3)
lwz r0, 0x00000020(r3)
cmplwi r0, 367
bne OriginalExit
bl Data
mflr r5
lfs f1, 0(r5)
lfs f2, 0x00000004(r5)
addi r4, r15, 0x000000B0
lwz r3, 0(r25)
bl ToPointFunc
lfs f1, 0x000000CC(r15)
lfs f2, 0x000000C8(r15)
lfs f3, 0x000000B0(r15)
lfs f4, 0x000000B0(r25)
fsubs f3, f4, f3
lfs f0, 0xFFFF8900(rtoc)
fcmpo cr0, f3, f0
bge+ not_reverse
lfs f0, 0xFFFF8910(rtoc)
fmuls f2, f0, f2
not_reverse:
lfs f3, 0x00000080(r15)
lfs f4, 0x00000084(r15)
fmuls f3, f3, f3
fmuls f4, f4, f4
fadds f3, f4, f3
frsqrte f4, f3
lfd f6, 0xFFFFA828(rtoc)
lfd f5, 0xFFFFA830(rtoc)
fmul f0, f4, f4
fmul f4, f6, f4
fnmsub f0, f3, f0, f5
fmul f4, f4, f0
fmul f0, f4, f4
fmul f4, f6, f4
fnmsub f0, f3, f0, f5
fmul f4, f4, f0
fmul f0, f4, f4
fmul f4, f6, f4
fnmsub f0, f3, f0, f5
fmul f0, f4, f0
fmul f0, f3, f0
frsp f0, f0
fmr f3, f0
lfs f4, 0x00000198(r15)
fmuls f3, f4, f3
bl Data
mflr r3
lfs f4, 0x00000008(r3)
fmuls f26, f4, f3
lis r0, 0x8007a8f0 @h
ori r0, r0, 0x8007a8f0 @l
mtctr r0
bctr
ToPointFunc:
mflr r0
stw r0, 4(r1)
stwu r1, 0xFFFFFFA8(r1)
stfd f31, 0x00000050(r1)
fmr f31, f2
stfd f30, 0x00000048(r1)
fmr f30, f1
stfd f29, 0x00000040(r1)
stw r31, 0x0000003C(r1)
stw r30, 0x00000038(r1)
addi r5, r1, 0x0000002C
lwz r31, 0x0000002C(r3)
addi r3, r4, 0
addi r4, r31, 0x000000B0
lis r12, 0x8000D4F8 @h
ori r12, r12, 0x8000D4F8 @l
mtctr r12
bctrl
lfs f1, 0x0000002C(r1)
lfs f0, 0x00000030(r1)
fmuls f2, f1, f1
lfs f3, 0x00000034(r1)
fmuls f1, f0, f0
lfs f0, 0xFFFFA818(rtoc)
fmuls f3, f3, f3
fadds f1, f2, f1
fadds f29, f3, f1
fcmpo cr0, f29, f0
ble lbl_8015BEF8
frsqrte f1, f29
lfd f3, 0xFFFFA828(rtoc)
lfd f2, 0xFFFFA830(rtoc)
fmul f0, f1, f1
fmul f1, f3, f1
fnmsub f0, f29, f0, f2
fmul f1, f1, f0
fmul f0, f1, f1
fmul f1, f3, f1
fnmsub f0, f29, f0, f2
fmul f1, f1, f0
fmul f0, f1, f1
fmul f1, f3, f1
fnmsub f0, f29, f0, f2
fmul f0, f1, f0
fmul f0, f29, f0
frsp f0, f0
stfs f0, 0x00000024(r1)
lfs f29, 0x00000024(r1)
lbl_8015BEF8:
fcmpo cr0, f29, f30
bge lbl_8015BF0C
lfs f0, 0x0000001C(sp)
stfs f0, 0x00000080(r31)
lfs f0, 0x00000020(sp)
stfs f0, 0x00000084(r31)
b lbl_8015BF40
lbl_8015BF0C:
addi r3, r1, 0x0000002C
lis r12, 0x8000D2EC @h
ori r12, r12, 0x8000D2EC @l
mtctr r12
bctrl
fmuls f1, f29, f31
lfs f0, 0x0000002C(r1)
fmuls f0, f0, f1
stfs f0, 0x0000002C(r1)
lfs f0, 0x00000030(r1)
fmuls f0, f0, f1
stfs f0, 0x00000030(r1)
lfs f0, 0x00000034(r1)
fmuls f0, f0, f1
stfs f0, 0x00000034(r1)
lbl_8015BF40:
lfs f0, 0x0000002C(r1)
stfs f0, 0x0000008C(r31)
lfs f0, 0x00000030(r1)
stfs f0, 0x00000090(r31)
lwz r0, 0x0000005C(r1)
lfd f31, 0x00000050(r1)
lfd f30, 0x00000048(r1)
lfd f29, 0x00000040(r1)
lwz r31, 0x0000003C(r1)
lwz r30, 0x00000038(r1)
addi r1, r1, 0x00000058
mtlr r0
blr
Data:
blrl
.float 5.0
.float 2.0
.float 0.5
OriginalExit:
lwz r0, 0x00000020(r3)
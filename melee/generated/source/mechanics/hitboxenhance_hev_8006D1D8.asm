lfs f0, 0xFFFF8870(rtoc)
stfs f0, 10676(r31)
lwz r3, 10692(r31)
cmplwi r3, 0
beq Exit
stwu sp, 0xFFFFFFD0(sp)
lfs f1, 0x0000004C(r3)
lfs f0, 0x00001854(r31)
fsubs f2, f1, f0
lfs f0, 0xFFFFC2A0(rtoc)
fmuls f2, f2, f0
stfs f2, 0x00000014(sp)
lwz r4, 0x00001868(r31)
lwz r4, 0x0000002C(r4)
lfs f1, 0x000000B0(r31)
lfs f0, 0x000000B0(r4)
fsubs f1, f1, f0
lfs f0, 0xFFFF8900(rtoc)
fcmpo cr0, f1, f0
bge+ CalcDiffY
fneg f2, f2
CalcDiffY:
lfs f1, 0x00000050(r3)
lfs f0, 0x00001858(r31)
fsubs f1, f1, f0
lfs f0, 0xFFFFC2A0(rtoc)
fmuls f1, f1, f0
stfs f1, 0x00000018(sp)
lfs f0, 0x000000CC(r4)
fadds f1, f0, f1
stfs f1, 0x00000090(r31)
lfs f1, 0x00000014(sp)
lfs f0, 0x000000C8(r4)
fadds f1, f0, f1
stfs f1, 0x0000008C(r31)
li r0, 0
stw r0, 10692(r31)
addi sp, sp, 0x00000030
Exit:
lwz r0, 0x00000024(sp)
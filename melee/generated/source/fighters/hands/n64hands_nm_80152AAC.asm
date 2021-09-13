lfs f1, 0x0000002C(r31)
fcmpo cr0, f1, f0
lfs f1, 0x00000098(r30)
blt Exit
fneg f1, f1
Exit:
fadds f1, f2, f1
lfs f1, 4124(r31)
fmuls f0, f0, f1
lfs f1, 0xFFFF8870(rtoc)
fcmpo cr0, f0, f1
bge+ Exit
fmr f0, f1
Exit:
fctiwz f0, f0
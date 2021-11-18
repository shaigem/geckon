lfs f0, 0xFFFF8870(rtoc)
fcmpo cr0, f1, f0
bge+ Exit
fmr f1, f0
Exit:
addi sp, sp, 64
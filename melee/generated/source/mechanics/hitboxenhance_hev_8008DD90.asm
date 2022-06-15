lfs f1, 11220(r29)
fadds f0, f0, f1
lfs f1, 0xFFFF8AF8(rtoc)
fcmpo cr0, f0, f1
bge OrigExit
fmr f0, f1
OrigExit:
stfs f0, 0x00002340(r29)
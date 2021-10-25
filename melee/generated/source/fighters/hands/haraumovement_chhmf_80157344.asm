lfs f1, 0x00002340(r31)
lfs f0, 0xFFFFA6B4(rtoc)
fadds f1, f1, f0
stfs f1, 0x00002340(r31)
bl Constants
mflr r3
lfs f1, 0x00002340(r31)
lfs f0, 0x00000000(r3)
fcmpo cr0, f1, f0
bge- MoveExit
b Exit
Constants:
blrl
.float 20.0
.float 3.0
.align 2
MoveExit:
lfs f1, 0x00000004(r3)
lfs f0, 0x00000080(r31)
fadds f0, f1, f0
stfs f0, 0x00000080(r31)
Exit:
lis r12, 0x8015735c @h
ori r12, r12, 0x8015735c @l
mtctr r12
bctr
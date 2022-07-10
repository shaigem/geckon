lbz r0, 11264(r31)
rlwinm. r0, r0, 0, 4
beq NormalCheck
li r3, 0
blr
NormalCheck:
lwz r4, 0xFFFFAEB4(r13)
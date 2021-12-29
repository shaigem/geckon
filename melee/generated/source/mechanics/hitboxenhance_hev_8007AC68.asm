lbz r0, 9340(r31)
rlwinm. r0, r0, 0, 4
beq NormalCheck
li r3, 0
blr
NormalCheck:
cmplwi r3, 361
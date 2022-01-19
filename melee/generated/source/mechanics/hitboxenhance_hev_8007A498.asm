cmplwi r18, 0
beq Exit
lbz r0, 16(r18)
rlwinm. r0, r0, 0, 8
beq Exit
lis r12, 0x8007a6a8 @h
ori r12, r12, 0x8007a6a8 @l
mtctr r12
bctr
Exit:
stw r3, 0x00000214(sp)
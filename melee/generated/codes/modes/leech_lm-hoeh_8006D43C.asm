lwz r29, 0x00001868(r30)
cmpwi r29, 0x00000000
beq Exit
lhz r3, 0x00000000(r29)
cmpwi r3, 0x00000004
beq Fighter
b Exit
Fighter:
lwz r29, 0x0000002C(r29)
SameTeamCheck:
mr r3, r29
mr r4, r30
lis r12, 0x800a3844 @h
ori r12, r12, 0x800a3844 @l
mtctr r12
bctrl
cmpwi r3, 1
beq Exit
Heal:
lwz r3, 0x0000183C(r30)
lbz r4, 0x00002224(r29)
rlwinm. r4, r4, 27, 31, 31
bne Exit
lwz r4, 0x000018F0(r29)
add r4, r4, r3
stw r4, 0x000018F0(r29)
Exit:
lwz r29, 0x0000183C(r30)
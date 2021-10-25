lwz r0, 0x00000004(r30)
cmpwi r0, 0x0000001B
beq IsMasterHand
cmpwi r0, 0x0000001C
bne Exit
IsCrazyHand:
li r4, 380
b CheckActionState
IsMasterHand:
li r4, 385
CheckActionState:
lwz r0, 0x00000010(r30)
cmpw r0, r4
bne Exit
SetBone:
li r3, 3
Exit:
lbz r0, 0x00002226(r29)
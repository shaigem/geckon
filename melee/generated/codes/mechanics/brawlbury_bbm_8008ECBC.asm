bne- InBury
b NotInBury
InBury:
HitEffectChecks:
lwz r3, 0x00001860(r29)
cmpwi r3, 9
beq OriginalBuryCheck
cmpwi r3, 10
beq OriginalBuryCheck
lfs f0, 0x00001850(r29)
bl Constants
mflr r3
lfs f1, 0x00000000(r3)
fcmpo cr0, f0, f1
ble OriginalBuryCheck
Unbury:
lbz r3, 0x00002220(r29)
b NotInBury
OriginalBuryCheck:
lis r12, 0x8008ecd4 @h
ori r12, r12, 0x8008ecd4 @l
mtctr r12
bctr
Constants:
blrl
.float 100.0
.align 2
NotInBury:
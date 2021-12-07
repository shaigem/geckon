cmpwi r3, 1
bgt OriginalExit
li r3, 0
OriginalExit:
cmpwi r28, 2
sth r3, 0x000018FA(r31)
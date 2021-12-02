cmpwi r3, 1
bgt OriginalExit
li r3, 0
OriginalExit:
sth r3, 0x000018FA(r31)
import geckon

defineCodes:
    createCode "Crazy Hand Enable Laser Move Input":
        patchWrite32Bits "80156ce0":
            # only for 20XX
            # re enable ch up+b move
            beq 0x6C

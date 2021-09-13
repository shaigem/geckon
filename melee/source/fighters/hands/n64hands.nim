import geckon


defineCodes:
    createCode "N64 Mh/Ch":
        description ""
        # TODO must set 803d3a44 to 80150870 mh physics wait move logic

        # prevent mh from teleporting back to starting pos
        patchWrite32Bits "801502a4":
            # set x to starting pos at start of idle action
            nop
        patchWrite32Bits "801502a8":
            # set y to starting pos at start of idle action
            nop
        patchWrite32Bits "8014fe8c":
            # set x to starting pos at end of idle action
            nop
        patchWrite32Bits "8014fe90":
            # set y to starting pos at end of idle action
            nop

        # fix direction for mh gun
        patchInsertAsm "801532ac":
            # f0 contains 0.0
            lfs f1, 0x2C(r31) # direction of fighter
            fcmpo cr0, f1, f0
            lfs f1, 0x00DC(r30) # x follow offset
            blt Exit
            fneg f1, f1
            Exit:
                fadds f1,f2,f1

        # fix direction for mh poke
        patchInsertAsm "80152aac":
            # f0 contains 0.0
            lfs f1, 0x2C(r31) # direction of fighter
            fcmpo cr0, f1, f0
            lfs f1, 0x98(r30) # x follow offset
            blt Exit
            fneg f1, f1
            Exit:
                fadds f1,f2,f1

        # fix direction for mh okukie (bg punch and slap)
        patchInsertAsm "80154254":
            lfs f0, -0x59B8(rtoc) # load -1.0
            stfs f0, 0x2C(r4)
            mr r3, r31 # orig line

        # fix direction for mh airplane flying
        patchInsertAsm "80153938":
            lfs f0, -0x59B8(rtoc) # load -1.0
            stfs f0, 0x2C(r31)
            lfs f1, -0x5A50(rtoc) # orig code line

        patchInsertAsm "80150844":
            # interrupt for Wait move logic
            # r3 has fighter data

            lfs f1, 0x0620(r3)
            lfs f0, -0x5B54(rtoc) # load 0.0
            fcmpo cr0, f1, f0
            beq Exit
            %branchLink("0x8007d9fc") # change direction based on joystick

            lfd f1, -0x7770(rtoc)
            li r4, 0
            fmul f1, f1, f0
            frsp f1, f1
            %branchLink("0x80075AF0") # change rot pitch, ensure that mh changes direction as soon as possible
            mr r3, r31 # restore r3
            Exit:
                lbz r3, 0x000C(r3) # original code line


        patchInsertAsm "80150870":
            # movement with analog in the Wait physics move logic
            %backup
            mr r29, r3
            lwz r31, 0x2C(r3)
            lwz r4, 0x10C(r31)
            lwz r30, 0x4(r4)
            %branchLink("0x80085134")

            lfs f0, 0x620(r31) # left stick x
            stfs f0, 0x80(r31) # set x vel

            SetVelY:
                lfs f1, -0x5B54(rtoc) # load 0.0
                lfs f0, 0x624(r31) # left stick y
                fcmpo cr0, f1, f0
                beq Exit # if stick y == 0.0, just exit
                stfs f0, 0x84(r31)

            Exit:
                mr r3, r29
                %restore
                %branch("0x8015088c")
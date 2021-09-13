import geckon

const
    EndOfFunctionAddress = "0x80157554"
    StartFollowFrame = 70
    EndFollowFrame = 190
    FollowSpeed = 0.4

defineCodes:
    createCode "Crazy Hand Spasm Follow Player":
        authors "Ronnie"
        description ""

        patchInsertAsm "8015749C": # start action
            lwz r3, 0x2C(r31)
            lfs f0, -0x5950(rtoc) # load 0
            stfs f0, 0x2340(r3) # store to our current frame var
            mr r3, r31 # original code line

        patchInsertAsm "80157538":
            %backup
            mr r29, r3
            lwz r31, 0x2C(r3)
            lwz r4, 0x10C(r31)
            lwz r30, 0x4(r4)
            %branchLink("0x80085134")

            lfs f1, 0x2340(r31) # load current frame
            lfs f0, -0x594C(rtoc) # loads float of 1.0
            fadds f1, f1, f0 # add 1 to our current frame var
            stfs f1, 0x2340(r31)

            bl Constants
            mflr r3

            lfs f0, 0x0(r3)
            fcmpo cr0, f1, f0 # if current frame <= StartFollowFrame
            %`ble-` Exit


            lfs f1, 0x2340(r31) # load current frame
            lfs f0, 0x4(r3) # load end follow frame
            fcmpo cr0, f1, f0
            %`bge-` Exit # TODO should we reset velocity?


            lfs f1, 0x8(r3) # load follow speed
            mr r3, r29
            %branchLink("0x8015C010")
#            b Exit

#            ResetVelocity:
#                lfs f0, -0x5950(rtoc)
#                stfs f0, 0x80(r31)

            Exit:
                mr r3, r29
                %restore
                %branch(EndOfFunctionAddress)

            Constants:
                blrl
                %`.float`(StartFollowFrame)
                %`.float`(EndFollowFrame)
                %`.float`(FollowSpeed)
                %`.align`(2)

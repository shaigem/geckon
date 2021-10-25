import geckon


const
    StartMoveFrame = 20
    MoveAmount = 3

defineCodes:
    createCode "Crazy Hand Harau Movement Fix":

        patchInsertAsm "801571cc": # haruloop animation callback
            lfs f1, -0x5950(rtoc) # load 0
            stfs f1, 0x2340(r31) # store to our current frame var
            mr r3, r30 # original line

        patchInsertAsm "80157228": # haruloop action start
            lfs f1, -0x5950(rtoc) # load 0
            stfs f1, 0x2340(r31) # store to our current frame var
            lwz r31, 0x2C(r30) # original line
        
        patchInsertAsm "80157344":
            lfs f1, 0x2340(r31) # load current frame
            lfs f0, -0x594C(rtoc) # loads float of 1.0
            fadds f1, f1, f0 # add 1 to our current frame var
            stfs f1, 0x2340(r31)

            bl Constants
            mflr r3

            lfs f1, 0x2340(r31) # load current frame
            lfs f0, 0x0(r3) # load start move frame
            fcmpo cr0, f1, f0
            %`bge-` MoveExit
            b Exit
            
            Constants:
                blrl
                %`.float`(StartMoveFrame)
                %`.float`(MoveAmount)
                %`.align`(2)

            MoveExit:
                lfs f1, 0x4(r3)
                lfs f0, 0x80(r31)
                fadds f0, f1, f0
                stfs f0, 0x80(r31)

            Exit:
                %branch("0x8015735c")


            
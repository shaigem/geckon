import geckon

# 80158894 - yubibomb physics move logic func
#[ 
* 80158894 00155474  7C 08 02 A6 */	mflr r0
/* 80158898 00155478  90 01 00 04 */	stw r0, 4(r1)
/* 8015889C 0015547C  94 21 FF F8 */	stwu r1, -8(r1)
/* 801588A0 00155480  4B F2 C8 95 */	bl func_80085134
/* 801588A4 00155484  80 01 00 0C */	lwz r0, 0xc(r1)
/* 801588A8 00155488  38 21 00 08 */	addi r1, r1, 8
/* 801588AC 0015548C  7C 08 03 A6 */	mtlr r0
/* 801588B0 00155490  4E 80 00 20 */	blr  ]#
# 80157D30 - fake out punch down physics move logic func 


#[ 802f1030 - yubibomb collision with stage (also spawns explosion GFX here)
802f10b4 - yubibomb collision with player ]#
const
    EndOfFunctionAddress = "0x801588B0"
    StartFollowFrame = 60
    EndFollowFrame = 230
    FollowSpeed = 0.3

defineCodes:

    createCode "Crazy Hand Yubibomb Enhancements":
        authors "Ronnie"
        description ""

        patchWrite32Bits "80272c2c":
            # description "Removes Crazy Hand's bomb GFX & SFX from playing when a bomb hits the ground"
            b 0x24 # branch to 80272c50, skipping GFX & SFX

        patchInsertAsm "801587E0": # yubibomb start action
            lfs f0, -0x5950(rtoc) # load 0
            stfs f0, 0x2340(r31) # store to our current frame var
            li r4, 0 # original code line

        patchInsertAsm "80158894":
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

echo Codes
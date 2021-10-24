import geckon


# 80156f34 - player request input for tag tsukamu CH
# 801503b0 - mh responds with action id to tag request
# 8015c4c4 - MH checks if ch is requesting for a tag team attack
# 17C - CH grab request action id
# 0x180 - CH taggoopa request action id


# Note the start actions make CH start the tag team action as well
# 80155194 - MH tagtsubusu start action
# 80155484 - MH taggoopa start action
# 801552f8 - MH taghakusyu start action

# 0x8015A2B0 - CH tagtsubusu start action
# 8015a560 - CH taggoopa start action
# 0x8015a3f4 - CH taghakusyu start action

# 0x134, 0x124, 0x138, 0x130
# 0x184 - tagcancel

# mh follow to grab: 
# 01 47 00 00 00 00 01 00 00 00 80 15 43 60 80 15 43 E8 80 15 44 2C 80 15 45 9C 80 07 61 C8
# 00 00 01 48 00 00 00 00 01 00 00 00 80 15 46 20 80 15 46 70 80 15 46 B4 80 15 46 D4 80 07 61 C8
#[ 

    MH captured success logic
    01 4A 00 00 00 00 01 00 00 00 80 15 4D 78 80 15 4D D0 80 15 4E 14 80 15 4E 74 80 07 61 C8
    MH grab damage logic
    01 4C 00 00 00 00 01 00 00 00 80 15 4B 2C 80 15 4B B0 80 15 4B F4 80 15 4C 54 80 07 61 C8
    
    MH Tagtsukamu logic
    01 53 00 00 00 00 01 00 00 00 80 15 55 E8 80 15 56 5C 80 15 56 A0 80 15 56 C0 80 07 61 C8
 
    MH Tagnigiru logic
    01 54 00 00 00 00 01 00 00 00 80 15 56 C4 80 15 57 B0 80 15 57 F4 80 15 58 14 80 07 61 C8
 ]#

const
    # Custom functions
    MhTagTsukamuFunction = "0x801510b8"
    ChTagTsukamuFunction = "0x8015b17c"
    MhTagTsukamuOnGrabSelfFunction = "0x801510bc"
    MhTagNigiruActionFunction = "0x801510c0"
    ChTagNigiruActionFunction = "0x8015b180"

    BossGetFighterGObj = "0x8015C3E8"
    BossUnk2Function = "0x8015C31C"
    SetupGrabParamsFunction = "0x8007E2D0"
    GrabSetGrabbableFlagFunction = "0x8007E2F4"
    MhTagTsukamuActionStateId = 385
    MhTagNigiruActionStateId = 386
    MhTagCancelActionStateId = 388
    ChTagTsukamuActionStateId = 380
    ChTagNigiruActionStateId = 381

defineCodes:

    createCode "Restore Tagtsukamu":
        authors "Ronnie"
        description "Restores the unused tag team attack for Master Hand and Crazy Hand"

        # MH responds to tagtsukamu request from ch
        patchInsertAsm "801503cc":

            cmpwi r3, 0x17C
            beq Setup
            bge OriginalExit

            Setup:
                lfs f1, 0x13C(r29) # x pos to move to
                %load(MhTagTsukamuFunction, r4)
                lfs f0, -0x5B54(rtoc) # load 0.0
                stfs f1, 0x2C(sp)
                mr r3, r28 # fighter gobj
                lfs f1, 0x140(r29) # y pos to move to
                addi r5, sp, 0x2C # points to x pos in stack
                stfs f1, 0x30(sp) # store y pos to stack
                stfs f0, 0x34(sp) # store z pos to stack
                %branch("0x80150460")

            OriginalExit:
                cmpwi r3, 381

        # MH Cancel action state patch
        patchInsertAsm "80154864":
            # r31 = fighter data
            lfs f1, -0x5A14(rtoc) # original line
            lwz r5, 0x10(r31) # load current action state ID
            cmpwi r5, {MhTagNigiruActionStateId}
            bne Exit
            li r4, {MhTagCancelActionStateId}
            Exit:
                %emptyBlock

        # Patch the proper bones to attach the grabbed fighter
        patchInsertAsm "800db390":
            # r30 = thrower fighter data
            # TODO check fighter id is mh or crazy hand
            lwz r0, 0x10(r30) # load current action state ID
            cmpwi r0, {MhTagTsukamuActionStateId}
            bne Exit
            li r3, 3 # use bone 3 for mh
            Exit:
                lbz r0, 0x2226(r29)


        # MH tagtsukamu action state function patch
        patchInsertAsm "801510b8":
            cmpwi r4, 343
            beq OriginalExit
            
            %backup
            # r29 = fighter gobj
            # r30 = ch fighter gobj
            # r31 = fighter data struct ptr
            mr r29, r3 # save fighter gobj
            lwz r31, 0x2C(r3) # save fighter data struct ptr
            # get ch fighter gobj
            li r3, 0x1C
            %branchLink(BossGetFighterGObj)
            mr r30, r3 # save ch fighter gobj
            # check if ch is in valid state
            %branchLink(BossUnk2Function)
            cmpwi r3, 0
            bne ChangeActionState
            # call tagtsukamu action state func for ch
            mr r3, r30 # r3 = fighter gobj of crazy hand
            %branchLink(ChTagTsukamuFunction)

            ChangeActionState:
                # make mh use the tagtsukamu action state
                stw r30, 0x1A5C(r31)
                mr r3, r29 # r3 = mh fighter gobj
                li r4, {MhTagTsukamuActionStateId}
                lfs f1, -0x59C8(rtoc)
                li r5, 0
                lfs f2, -0x59C4(rtoc)
                li r6, 0
                fmr f3, f1
                %branchLink("0x800693AC")
                mr r3, r29
                %branchLink("0x8006EBA4")

            # Setup the grab parameters
            %load(MhTagTsukamuOnGrabSelfFunction, r5)# OnGrabFighter_Self
            %load("0x80155A58", r7) # OnGrabFighter_Victim
            mr r3, r31
            li r4, 0x80
            li r6, 0
            %branchLink(SetupGrabParamsFunction)
            li r0, 0
            stw r0, 0x2360(r31)

            %restore
            blr

            OriginalExit:
                stw r0, 0x0004(sp)

#[         # Patch animation move logic for tagtsukamu for ch
        # Will switch to the Tagnigiru action if mh has grabbed someone        
        patchInsertAsm "8015a728":
            # r30 = fighter gobj
            # r31 = fighter data
            li r3, 0x1B # mh ID
            %branchLink(BossGetFighterGObj)
            lwz r3, 0x2C(r3) # fighter data for mh

            lwz r0, 0x2360(r3)
            cmpwi r0, 1
            bne Exit

            mr r3, r30
            %branchLink(ChTagNigiruActionFunction)
            # TODO do i need to store 1a5c(r31?)
            %branch("0x8015a738")
            
            Exit:
                li r0, 0 ]#

        # Patch animation move logic for tagtsukamu for mh
        # Will switch to the Tagnigiru action if mh has grabbed someone
        # TODO pick a better injection spot
        patchInsertAsm "80155634":
            # r30 = fighter gobj
            # r31 = fighter data
            lwz r0, 0x2360(r31)
            cmpwi r0, 1
            bne Exit

            # we grabbed someone, so now run the nigiru action function
            mr r3, r30
            %branchLink(MhTagNigiruActionFunction)
            %branch("0x80155644")

            Exit:
                li r0, 0

        # CH Tagnigiru action function
        # input r3 = fighter gobj
        patchInsertAsm "8015b180":
            cmpwi r4, 387
            beq OriginalExit

            %backup

            # prolog
            # r31 = fighter gobj
            # r30 = fighter data
            mr r31, r3
            lwz r30, 0x2C(r3)

            # set unknown var to 0
            li r0, 0
            stw r0, 0x2204(r30)

            # change action state
            li r4, {ChTagNigiruActionStateId}
            lfs f1, -0x59C8(rtoc)
            li r5, 0
            lfs f2, -0x59C4(rtoc)
            li r6, 0
            fmr f3, f1
            %branchLink("0x800693AC")
            mr r3, r31
            %branchLink("0x8006EBA4")
            # end func
            %restore
            blr
            
            OriginalExit:
                li r6, 0

        # MH Tagnigiru action function
        # input r3 = fighter gobj
        patchInsertAsm "801510c0":
            cmpwi r4, 343
            beq OriginalExit

            %backup

            # prolog
            # r31 = fighter gobj
            # r30 = fighter data
            mr r31, r3
            lwz r30, 0x2C(r3)

            # set unknown var to 0
            li r0, 0
            stw r0, 0x2204(r30)

            # change action state
            li r4, {MhTagNigiruActionStateId}
            lfs f1, -0x59C8(rtoc)
            li r5, 0
            lfs f2, -0x59C4(rtoc)
            li r6, 0
            fmr f3, f1
            %branchLink("0x800693AC")
            mr r3, r31
            %branchLink("0x8006EBA4")

            # set unknown...
            lbz r0, 0x2222(r30)
            li r3, 1
            rlwimi r0, r3, 5, 26, 26
            stb r0, 0x2222(r30)

            # call setgrabbable flag
            mr r3, r30
            li r4, 511
            %branchLink(GrabSetGrabbableFlagFunction)

            # kill all velocity
            mr r3, r31
            %branchLink("0x8007E2FC")

            # change victim's A/S to CaptureDamageMasterHand
            lwz r3, 0x1A58(r30)
            %branchLink("0x80155B80")

            # end func
            %restore
            blr
            
            OriginalExit:
                stwu sp, -0x0020(sp)

        # MhTagTsukamuOnGrabSelfFunction
        patchInsertAsm "801510bc":
            cmpwi r4, 343
            beq OriginalExit

            %backup
            li r4, 0
            li r0, 1
            lfs f0, -0x5A14(rtoc)
            lwz r5, 0x2C(r3)
            stfs f0, 0x88(r5)
            stfs f0, 0x84(r5)
            stfs f0, 0x80(r5)
            stw r0, 0x2360(r5)
            lbz r0, 0x221E(r5)
            rlwimi r0, r4, 1, 30, 30
            stb r0, 0x221E(r5)
            
            mr r31, r3
            # play catch gfx
            lwz r3, 0x1A58(r5)
            li r4, 537 # id
            li r5, 5 # bone
            li r6, 0
            li r7, 0
            addi r8, sp, {BackupFreeSpaceOffset}
            addi r9, sp, {BackupFreeSpaceOffset} + 0xC
            li r0, 0
            stw r0, 0x0(r8)
            stw r0, 0x4(r8)
            stw r0, 0x8(r8)
            li r0, 0
            stw r0, 0x0(r9)
            stw r0, 0x4(r9)
            stw r0, 0x8(r9)
            %branchLink("0x8009f834")
            # play catch sound
            lwz r3, 0x2C(r31)
            lis r4, 0x5
            subi r4, r4, 7663
            li r5, 127 # volume
            li r6, 64
            %branchLink("0x80088148") # play char sfx
            %restore
            blr
            
            OriginalExit:
                li r6, 0

        # CH tagtsukamu action state func patch
        patchInsertAsm "8015b17c":
            cmpwi r4, 387
            beq OriginalExit

            %backup
            # r31 = fighter gobj
            # r3 = fighter gobj
            mr r31, r3 # backup fighter gobj
            li r4, {ChTagTsukamuActionStateId}
            lfs f1, -0x59C8(rtoc)
            li r5, 0
            lfs f2, -0x59C4(rtoc)
            li r6, 0
            fmr f3, f1
            %branchLink("0x800693AC")
            mr r3, r31
            %branchLink("0x8006EBA4")
            %restore
            blr
            OriginalExit:
                stw r0, 0x4(sp)
            

#[         # MH Tagtsukamu Action Setup Function
        patchInsertAsm "8015143C":
            # r31 has fighter gobj saved
            
            # r3 has fighter gobj here still
            li r4, 385 # mh Tagtsukamu action id
            lfs f1, -0x59C8(rtoc)
            li r5, 0
            lfs f2, -0x59C4(rtoc)
            li r6, 0
            fmr f3, f1
            %branchLink("0x800693AC")
            mr r3, r31
            %branchLink("0x8006EBA4")

            # setup grab
            %load("0x80151440", r5)# OnGrabFighter_Self
            %load("0x80155A58", r7) # OnGrabFighter_Victim
            lwz r3, 0x2C(r31)
            li r4, 0x100
            li r6, 0
            %branchLink("0x8007E2D0") # setupGrabParameters
            li r0, 0
            stw r0, 0x2360(r31)

            Epilog:
                %branch("0x80151470")

        # MH Tagtsukamu OnGrabFighter_Self callback 
        patchInsertAsm "80151440":
            %backup
            addi r31, r3, 0
            li r4, 0
            li r0, 1
            lwz r5, 0x2C(r3)
            stw r0, 0x2360(r5) # ???
            lbz r0, 0x221E(r5)
            rlwimi r0, r4, 1, 30, 30
            stb r0, 0x221E(r5)

            mr r3, r31 # fighter gobj
            li r4, 386 # mh Tagnigiru action id
            lfs f1, -0x59C8(rtoc)
            li r5, 0
            lfs f2, -0x59C4(rtoc)
            li r6, 0
            fmr f3, f1
            %branchLink("0x800693AC")
            mr r3, r31
            %branchLink("0x8006EBA4")

#             lwz r30, 0x2C(r31) # load fighter data struct
#             lbz r0, 0x2222(r30)
#             li r3, 1
#             rlwimi r0, r3, 5, 26, 26
#             stb r0, 0x2222(r30)
#             mr r3, r30
#             li r4, 0x1ff
#             %branchLink("0x8007E2F4") # Grab_SetGrabbableFlag
# #            mr r3, r31
#             lwz r3, 0x1A58(r30)
#             %branchLink("0x80155B80") # Set grabbed target's action to CapturedamageMasterhand


            %restore
            blr
#            %branch("0x80151470")


 ]#
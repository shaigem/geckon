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
    GenericTsukamuFunction = "0x8017c0c8"
    MhTagTsukamuSetupFunction = "0x801510b8"
    ChTagTsukamuFunction = "0x8015b17c"
    MhTagTsukamuOnGrabSelfFunction = "0x801510bc"
    TagNigiruActionFunction = "0x801510c0"

    BossGetFighterGObj = "0x8015C3E8"
    BossUnk2Function = "0x8015C31C"
    SetupGrabParamsFunction = "0x8007E2D0"
    GrabSetGrabbableFlagFunction = "0x8007E2F4"
    MhTagTsukamuActionStateId = 385
    MhTagNigiruActionStateId = 386
    MhTagCancelActionStateId = 388
    ChTagTsukamuActionStateId = 380
    ChTagNigiruActionStateId = 381
    ChTagCancelActionStateId = 383
    MagicNumber = 69

# mh y = 34
# ch y = 34
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
                %load(MhTagTsukamuSetupFunction, r4)
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

        # CH Cancel action state patch
        patchInsertAsm "801590c0":
            # r31 = fighter data
            lfs f1, -0x58F4(rtoc) # original line
            lwz r5, 0x10(r31) # load current action state ID
            cmpwi r5, {ChTagNigiruActionStateId}
            bne Exit
            li r4, {ChTagCancelActionStateId}
            Exit:
                %emptyBlock

        # Patch the proper bones to attach the grabbed fighter
        patchInsertAsm "800db390":
            # r30 = thrower fighter data
            # r0 and r4 are good to use
            lwz r0, 0x4(r30) # internal char id
            cmpwi r0, 0x1B
            beq IsMasterHand
            cmpwi r0, 0x1C
            bne Exit

            IsCrazyHand:
                li r4, {ChTagTsukamuActionStateId}
                b CheckActionState

            IsMasterHand:
                li r4, {MhTagTsukamuActionStateId}
                
            CheckActionState:
                lwz r0, 0x10(r30) # load current action state ID
                cmpw r0, r4
                bne Exit
                    
            SetBone:
                li r3, 3 # use bone 3

            Exit:
                lbz r0, 0x2226(r29)

        # Patch animation move logic for tagtsukamu for mh
        # Will switch to the Tagnigiru action if mh has grabbed someone
        patchInsertAsm "8015562c":
            # r30 = fighter gobj
            # r31 = fighter data
            lwz r0, 0x2360(r31)
            cmpwi r0, 1
            bne Exit

            # We grabbed someone, so now run the nigiru action function
            mr r3, r30
            %branchLink(TagNigiruActionFunction)
            %branch("0x80155644") # branch to epilog

            Exit:
                mr r3, r30

        # Patch animation move logic for tagtsukamu for ch
        # Will switch to the Tagnigiru action if ch has grabbed someone
        patchInsertAsm "8015a714":
            # r30 = fighter gobj
            # r31 = fighter data
            # r3 = fighter gobj
            lwz r0, 0x2360(r31)
            cmpwi r0, 1
            bne Exit

            # We grabbed someone, so now run the nigiru action function
            mr r3, r30
            %branchLink(TagNigiruActionFunction)
            %branch("0x8015a738") # branch to epilog

            Exit:
                lfs f0, -0x5868(rtoc)

        # Animation Move Logic for Tagnigiru (CH)
        patchInsertAsm "8015a7d0":
            # r30 = fighter gobj
            # r31 = fighter data
            # r3 here is fighter gobj
            lwz r31, 0x2C(r30)

            lwz r0, 0x2200(r31)
            cmplwi r0, 0
            beq Exit
            
            li r0, 0
            stw r0, 0x2200(r31)
            
            li r4, 339
            lwz r3, 0x1A58(r31)
            %branchLink("0x8015B850")

            lwz r3, 0x1A58(r31)
            cmplwi r3, 0
            beq Exit

            mr r31, r3
            lwz r3, 0x2C(r30) # source fighter data
            li r4, 0
            # r31 from this point contains the victim's fighter gobj
            %branchLink(GrabSetGrabbableFlagFunction)
            mr r3, r30
            mr r4, r31
            %branchLink("0x800DE2A8") # ThrowVictim_Prefunction

            # Damage and Hitstun function?
            mr r3, r31 # victim fighter gobj
            # Load victim's fighter data into r4
            lwz r4, 0x2C(r3)
            # Reverse facing direction
            lfs f1, 0x1844(r4)
            lfs f0, -0x58D0(rtoc)
            fmuls f0, f1, f0
            stfs f0, 0x1844(r4)
            # Setup remaining parameter vars
            li r4, 0
            li r5, 0
            %branchLink("0x800DE7C0") # damage and hitstun?

            Exit:
                # r3 must be fighter gobj
                mr r3, r30
                %branchLink("0x8015c358")

#[         # Generic Tagtsukamu action state function
        patchInsertAsm "8017c0c8":
            # inputs
            # r3 = source fighter gobj
            # r4 = partner char id
            # r5 = Tagtsukamu state id
            # r6 = ? for grab... 0x80 mh or 0x100 ch
            # r7 = OnGrabFighter_Self cb
            # r8 = OnGrabFighter_Victim cb
            # f1 = ??
            # f2 = ??

            # Check if valid char ID for hands
            cmpwi r4, 0x1C
            beq Start
            cmpwi r4, 0x1B
            bne OldExit

            Start:

                Backup:
                    %backup
                    # backed up registers
                    # r31 = fighter data
                    # r30 = partner gobj
                    # r29 = Tagtsukamu action state id
                    # r28 = ? for grab
                    # r27 = OnGrabFighter_Self cb
                    # r26 = OnGrabFighter_Victim cb
                    lwz r31, 0x2C(r3) # source fighter data
                    mr r29, r5
                    mr r28, r6
                    mr r27, r7
                    mr r26, r8

                # Get partner gobj
                # r3 = partner char id
                mr r3, r4
                %branchLink(BossGetFighterGObj) # returns gobj in r3
                stw r3, 0x1A5C(r31) # store partner gobj
                mr r30, r3 # save partner gobj

                # Check if source is Master Hand
                # We will switch Crazy Hand's Action State to Tagtsukamu
                lwz r4, 0x4(r31) # internal char id
                cmpwi r4, 0x1B
                bne ChangeActionState
                # Check partner's state??
                %branchLink(BossUnk2Function)
                cmpwi r3, 0
                bne ChangeActionState
                # Change Crazy Hand's Action State
                mr r3, r30 # use partner's gobj
                li r4, 0x1B
                li r5, {ChTagTsukamuActionStateId}
                li r6, 0x100
                %load("0x80169288", r7)
                %load("0x8016b548", r8)
                lfs f1, -0x58F4(rtoc)
                lfs f2, -0x58F8(rtoc)
                %branchLink("0x8017c0c8")

                # Change action state to Tagtsukamu
                ChangeActionState:
                    # also uses f1 and f2
                    lwz r3, 0(r31)
                    li r4, r29
                    li r5, 0
                    li r6, 0
                    fmr f3, f1
                    %branchLink("0x800693AC")
                    lwz r3, 0(r31)
                    %branchLink("0x8006EBA4")

                # Setup Grab parameters
                %load(MhTagTsukamuOnGrabSelfFunction, r5)# OnGrabFighter_Self
                %load("0x80155A58", r7) # OnGrabFighter_Victim
                mr r3, r31 # fighter data
                li r4, r28
                li r6, 0
                %branchLink(SetupGrabParamsFunction)
                li r0, 0
                stw r0, 0x2360(r31)

            %restore
            blr
            
            OldExit:
                mflr r0 ]#

        # MH Tagtsukamu action state function patch
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
            stw r30, 0x1A5C(r31)
            # check if ch is in valid state
            %branchLink(BossUnk2Function)
            cmpwi r3, 0
            bne SetupForMasterHand

            SetupForCrazyHand:
                # Initial setup for Crazy Hand
                # Get MH fighter gobj
                # TODO don't think this is necessary, just store MH's object from before
                li r3, 0x1B
                %branchLink(BossGetFighterGObj)
                lwz r4, 0x2C(r30)
                stw r3, 0x1A5C(r30)

                # Call the SetupActionStateAndGrab function
                mr r3, r30
                li r4, {ChTagTsukamuActionStateId}
                li r5, 0x100
                bl TagTsukamuOnGrabSelf
                mflr r6
#                %load("0x80159288", r6)
                %load("0x8015b548", r7)
                lfs f1, -0x58F4(rtoc)
                lfs f2, -0x58F8(rtoc)
                bl SetupActionStateAndGrab

            SetupForMasterHand:
                mr r3, r29
                li r4, {MhTagTsukamuActionStateId}
                li r5, 0x80
                bl TagTsukamuOnGrabSelf
                mflr r6
                %load("0x80155A58", r7) # TODO make as constant
                lfs f1, -0x59C8(rtoc)
                lfs f2, -0x59C4(rtoc)
                bl SetupActionStateAndGrab
            
            EndFunction:
                %restore
                blr

            # Custom Functions
            SetupActionStateAndGrab:
                # inputs
                # r3 = source fighter gobj
                # r4 = Tagtsukamu state id
                # r5 = ? for grab... 0x80 mh or 0x100 ch
                # r6 = OnGrabFighter_Self cb
                # r7 = OnGrabFighter_Victim cb
                # f1 = ??
                # f2 = ??

                # backed registers
                # r31 = fighter data
                # r30 = fighter obj
                # r29 = 0x80 or 0x100
                # r28 = r6 OnGrabFighter_Self
                # r27 = r7 OnGrabFighter_Victim
                %backup
                lwz r31, 0x2C(r3)
                # r4 is not backed up here since it's used immediately after
                mr r30, r3
                mr r29, r5
                mr r28, r6
                mr r27, r7

                # Change action state to given tagtsukamu state from r4
                # r3 = fighter obj
                # r4 = tagtsukamu state id
                li r5, 0
                li r6, 0
                fmr f3, f1
                %branchLink("0x800693AC")
                mr r3, r30 # fighter obj
                %branchLink("0x8006EBA4")

                # Setup Grab parameters
                mr r5, r28
                mr r7, r27
                mr r3, r31 # uses fighter data
                mr r4, r29
                li r6, 0
                %branchLink(SetupGrabParamsFunction)
                li r0, 0
                stw r0, 0x2360(r31)

                %restore
                blr
            
            TagTsukamuOnGrabSelf:
                # inputs
                # r3 = fighter gobj
                blrl
                %backup
                # backed up registers
                # r31 = fighter gobj
                # r30 = fighter data
                mr r31, r3
                lwz r30, 0x2C(r3)

                # Setup variables
                li r4, 0
                li r0, 1
                # -0x5a14 for MH, -0x58f4 for CH
                lfs f0, -0x5A14(rtoc)
                stfs f0, 0x88(r30)
                stfs f0, 0x84(r30)
                stfs f0, 0x80(r30)
                stw r0, 0x2360(r30)
                lbz r0, 0x221E(r30)
                rlwimi r0, r4, 1, 30, 30
                stb r0, 0x221E(r30)

                # Play Catch GFX for the caught fighter
                lwz r3, 0x1A58(r30) # load caught fighter gobj
                li r4, 537 # gfx id
                li r5, 5 # bone
                li r6, 0
                li r7, 0
                addi r8, sp, {BackupFreeSpaceOffset}
                addi r9, sp, {BackupFreeSpaceOffset} + 0xC
                # Setup scatter for gfx
                li r0, 0
                stw r0, 0x0(r8)
                stw r0, 0x4(r8)
                stw r0, 0x8(r8)
                # setup offsets? for gfx
                li r0, 0
                stw r0, 0x0(r9)
                stw r0, 0x4(r9)
                stw r0, 0x8(r9)
                %branchLink("0x8009f834") # play gfx

                # Play catch sound effect
                mr r3, r30
                lis r4, 0x5
                subi r4, r4, 7663
                li r5, 127 # volume
                li r6, 64
                %branchLink("0x80088148") # play char sfx
                %restore
                blr

            OriginalExit:
                stw r0, 0x0004(sp)

        # TagNigiruActionFunction
        patchInsertAsm "801510c0":
            cmpwi r4, 343
            beq OriginalExit

            # inputs
            # r3 = fighter gobj
            %backup
            # backed up registers
            # r31 = fighter data
            # r30 = attributes ptr
            # r29 = fighter obj
            # r28 = ? ptr
            # r27 = ? ptr
            # r26 = ? ptr
            # r25 = address to changing victim's A/S
            mr r29, r3
            lwz r31, 0x2C(r3)
            lwz r6, 0x10C(r31)
            lwz r30, 0x4(r6)

            # Setup variables for mh or ch
            # No need to check for invalid IDs
            # Never used outside of mh or ch
            lwz r4, 0x4(r31) # internal char id
            cmpwi r4, 0x1B
            bne SetupChVars
            
            SetupMhVars:
                addi r28, r30, 0x118
                addi r27, r30, 0x11C
                subi r26, rtoc, 0x5A00
                %load("0x80155B80", r25)
                # Setup for change action state
                li r4, {MhTagNigiruActionStateId}
                lfs f1, -0x5A00(rtoc)
                lfs f2, -0x59FC(rtoc)
                fmr f3, f1
                b ChangeActionState

            SetupChVars:
                addi r28, r30, 0xD0
                addi r27, r30, 0xD4
                subi r26, rtoc, 0x58E0
                %load("0x8015B670", r25)
                # Setup for change action state
                li r4, {ChTagNigiruActionStateId}
                lfs f1, -0x58E0(rtoc)
                lfs f2, -0x58DC(rtoc)
                fmr f3, f1

            ChangeActionState:
                # Change action state
                li r0, 0
                li r5, 0
                li r6, 0
                %branchLink("0x800693AC")
                mr r3, r29
                %branchLink("0x8006EBA4")
    
            lbz r0, 0x2222(r31)
            li r3, 1
            rlwimi r0, r3, 5, 26, 26
            stb r0, 0x2222(r31)

            # Call SetGrabbable flag func
            mr r3, r31
            li r4, 511
            %branchLink(GrabSetGrabbableFlagFunction)

            # Kill all velocity
            mr r3, r29
            %branchLink("0x8007E2FC")

            # Change victim A/S to CaptureDamage{Master/Crazy}Hand
            lwz r3, 0x1A58(r31)
            mtctr r25
            bctrl
            
            lfs f0, 0(r28)
            stfs f0, 0x234C(r31)
            lfs f0, 0(r27)
            stfs f0, 0x2350(r31)
            lfs f0, 0(r26)
            stfs f0, 0x2354(r31)

            # End
            %restore
            blr

            OriginalExit:
                stwu sp, -0x0020(sp)

#[         # MH Tagnigiru action function
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
                stwu sp, -0x0020(sp) ]#
#[ 
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
                li r6, 0 ]#

#[         # CH tagtsukamu action state func patch
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
                stw r0, 0x4(sp) ]#
            

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
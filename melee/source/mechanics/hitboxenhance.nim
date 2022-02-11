import geckon
import ../common/dataexpansion
#[- code: 0xF1
  name: Hitbox Extension
  parameters:
  - name: Hitbox ID
    bitCount: 3
  - name: Apply to Hitbox IDs 0-7
    bitCount: 1
    enums:
    - false
    - true
  - name: Hitlag Multiplier %
    bitCount: 12
  - name: SDI Multiplier %
    bitCount: 12
  - name: Shieldstun Multiplier %
    bitCount: 12
  - name: Hitstun Modifier
    bitCount: 8
    signed: true
  - name: Set Weight
    bitCount: 1
    enums:
      - false
      - true
  - name: Angle Flipper
    bitCount: 2
    enums:
      - Regular
      - Current Facing Direction
      - Opposite Current Facing Direction
  - name: Stretch
    bitCount: 1
    enums:
      - false
      - true
  - name: Flinchless
    bitCount: 1
    enums:
      - false
      - true
  - name: Disable Meteor Cancel
    bitCount: 1
    enums:
      - false
      - true
  - name: No Stale
    bitCount: 1
    enums:
      - false
      - true
  - name: Affect Only Throw Hitbox
    bitCount: 1
    enums:
      - false
      - true]#

const
    CodeVersion = "v1.8.0"
    CodeName = "Hitbox Extension " & CodeVersion
    CodeAuthors = ["sushie"]
    CodeDescription = "Allows you to modify hitlag, SDI, hitstun and more!"
    HeaderInfo = MexHeaderInfo
    ExtFighterDataOffset = HeaderInfo.fighterDataSize
    ExtItemDataOffset = HeaderInfo.itemDataSize

const
    CustomFunctionReadEvent = "0x801510e0"
    CustomFunctionInitDefaultEventVars = "0x801510e4"
    CustomFuncResetGravityAndFallSpeed = "0x801510e8"

defineCodes:
    createCode CodeName:
        description CodeDescription
        authors CodeAuthors

        patchInsertAsm "8007893c":
            addi r30, r3, 0
            cmplw r3, r5
            bne Exit
            mr r4, r3
            Exit:
                %emptyBlock

        patchInsertAsm "80077414":
            # r28 = defender data
            # r26 = attacker data
            # r27 = hit struct
            lwz r3, 0(r26)
            mr r4, r27
            # get ext hit struct
            %branchLink("0x801510d4") # getExtHit
            cmplwi r3, 0
            beq Exit
            lbz r3, {extHitOff(hitFlags)}(r3)
            %`rlwinm.`(r3, r3, 0, flag(hfNoStale))
            beq Exit
            lwz r5, 0(r26)
            Exit:
                lwz r3, 0(r26) # orig code line

        patchInsertAsm "800789b8":
            addi r30, r4, 0
            cmplw r3, r5
            bne Exit
            mr r4, r3
            Exit:
                %emptyBlock

        # HURTBOX HIT - Article Hitbox - Attacker+Victim (Hitbox_ProjectileLogicOnPlayer)
        patchInsertAsm "80078334":
            # r28 = defender data
            # r26 = item attacker data
            # r27 = hit struct
            lwz r3, 0x4(r26)
            mr r4, r27
            # get ext hit struct
            %branchLink("0x801510d4") # getExtHit
            cmplwi r3, 0
            beq Exit
            lbz r3, {extHitOff(hitFlags)}(r3)
            %`rlwinm.`(r3, r3, 0, flag(hfNoStale))
            beq Exit
            lwz r5, 0x4(r26)
            Exit:
                lwz r3, 0x4(r26) # orig code line

        # Patch Disable Meteor Cancel
        patchInsertAsm "8007ac70":
            # r31 = fighter data
            lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r31)
            %`rlwinm.`(r0, r0, 0, flag(ffDisableMeteorCancel))
            beq NormalCheck
            li r3, 0 # cannot meteor cancel
            blr
            NormalCheck:
                lwz r4, -0x514C(r13) # original code line

        # Damage_BranchToDamageHandler - Patch Custom Windbox Function
        patchInsertAsm "8008edb0":
            # r31 = ft/it gobj
            # r29 = ft/it data

            lbz r3, {extFtDataOff(HeaderInfo, fighterFlags)}(r29)
            %`rlwinm.`(r3, r3, 0, flag(ffHitByFlinchless))
            beq UnhandledExit

            lbz r0, 0x2222(r29)
            %`rlwinm.`(r0, r0, 27, 31, 31) # 0x20 grab?
            beq lbl_800C355C
            b HandledExit

            lbl_800C355C:
                lbz r0, 0x2071(r29) # ???
                rlwinm r0, r0, 28, 28, 31
                cmpwi r0, 12
                bge HandleWindbox
                cmpwi r0, 10 # grab?
                beq HandleWindbox 
                cmpwi r0, 9 # hanging off ledge??
                bge HandledExit
                b HandleWindbox

            HandleWindbox:
                mr r3, r31
                bl Damage_Windbox

            HandledExit:
                # branches to the end of the Damage_BranchToDamageHandler, meaning that we handled the damage
                %branch("0x8008f71c")

            Damage_Windbox:
                mflr r0
                stw r0, 0x0004 (sp)
                lis r0, 0x4330
                stwu sp, -0x0040 (sp)
                stfd f31, 0x0038 (sp)
                stfd f30, 0x0030 (sp)
                stfd f29, 0x0028 (sp)
                stw r31, 0x0024 (sp)
                lwz r5, 0x002C (r3)
                mr r31, r5
#                BranchToUnk:
#                    %branchLink("0x8006D044") # Hitlag related functions for grab victims and EnterHitlag callbacks?
                lbl_800C3634:
                    lwz r3, -0x514C(r13)
                    lfs f0, 0x100(r3) # 0.03
                    lfs f1, 0x1850(r31) # forced applied
                    fmuls f31, f1, f0 # forced applied * 0.03
                    CheckAttackAngle:
                        mr r3, r31
                        lfs f1, 0x1850(r31) # forced applied
                        %branchLink("0x8008D7F0") # CheckAttackAngle
                fmr f30, f1 # save AttackRadians into f30
                %branchLink("0x80326240") # cos
                fmuls f29, f31, f1 # f29 = (forced Applied * 0.03) * result of cos
                fmr f1, f30 # put AttackRadians back into f1
                %branchLink("0x803263D4") # sin
                lwz r0, 0x00E0 (r31) # check air state
                fmuls f2,f31,f1 # (force_applied * 0.03) * result of sin
                cmpwi r0, 1 # if in the air
                bne StoreVelocityGrounded
                lfs f0, 0x1844(r31) # dmg_direction
                mr r3, r31
                fneg f1, f29 # -((forced Applied * 0.03) * result of cos)
                fmuls f1, f1, f0 # -((forced Applied * 0.03) * result of cos) * direction
                %branchLink("0x8008DC0C") # StoreVelocity/CheckForKBStack
                lfs f0, -0x6D08(rtoc)
                stfs f0, 0x00F0(r31)
                b StoreSlotLastDamaged
                StoreVelocityGrounded:
                    # called when hit on the GROUND
                    fneg f1, f29 # -((forced Applied * 0.03) * result of cos)
                    lfs f0, 0x1844(r31) # dmg_direction
                    fmuls f0, f1, f0
                    fmr f1, f0
                    stfs f1, 0xF0(r31)
                    mr r3, r31
                    lfs f0, 0x0844(r31) # -0?
                    fneg f0,f0
                    fmuls f2, f0, f1
                    %branchLink("0x8008DC0C") # StoreVelocity/CheckForKBStack
                StoreSlotLastDamaged:
                    li r3, 0
                    stw r3, 0x18AC(r31) # store time_last_hit = 0
#                    mr r3, r31
#                    %branchLink("0x800804FC") # SlotLastDamaged Make Self If On Ground
                    lwz r0, 0x0044 (sp)
                    lfd f31, 0x0038 (sp)
                    lfd f30, 0x0030 (sp)
                    lfd f29, 0x0028 (sp)
                    lwz r31, 0x0024 (sp)
                    addi sp, sp, 64
                    mtlr r0
                    blr

            UnhandledExit:
                mr r3, r31

        #[Notes on hitlag on invincibility
            80077438 - this is where it spawns the gfx when you hit an invincible opponent
            - good spot for adding hitlag multipliers if I decided to do it for invincible hits ]#

        patchInsertAsm "801510d4":

            cmpwi r4, 343
            %`beq-`(OriginalExit)
            
            # inputs
            # r3 = attacker gobj
            # r4 = attacker hit ft/it hit struct ptr
            # returns
            # r3 = ptr to ExtHit of attacker
            cmplwi r3, 0
            beq Invalid
            cmplwi r4, 0
            beq Invalid

            # stack
            # 0x14 - # of extra hitboxes
            # 0x10 - attacker data ptr + Extra Ft/ItHit struct offset
            stwu sp, -0x18(sp)
            # calculate & store # of extra hitboxes to account for
            li r0, {NewHitboxCount - OldHitboxCount}
            stw r0, 0x14(sp)
            # set the initial loop count
            li r0, {OldHitboxCount}
            mtctr r0

            # check attacker type
            lhz r0, 0(r3)
            lwz r3, 0x2C(r3) # fighter data
            cmplwi r0, 4 # fighter type
            beq GetExtHitForFighter
            cmplwi r0, 6 # item type
            beq GetExtHitForItem
            b Invalid

            GetExtHitForItem:
                addi r5, r3, {extItDataOff(HeaderInfo, newHits) - ItHitSize} # attacker data ptr + Extra FtHit struct offset
                stw r5, 0x10(sp)
                addi r5, r3, 1492 # attacker data ptr + hit struct offset
                addi r3, r3, {ExtItemDataOffset} # attacker data ptr + Exthit struct offset
                li r0, {ItHitSize}
            b GetExtHit

            GetExtHitForFighter:
                addi r5, r3, {extFtDataOff(HeaderInfo, newHits) - FtHitSize} # attacker data ptr + Extra ItHit struct offset
                stw r5, 0x10(sp)
                addi r5, r3, 2324 # attacker data ptr + hit struct offset
                addi r3, r3, {ExtFighterDataOffset} # attacker data ptr + Exthit struct offset
                li r0, {FtHitSize}

            GetExtHit:
                # uses
                # r3 = points to ExtHit struct offset
                # r4 = target hit struct ptr
                # r5 = temp var holding our current hit struct ptr
                # r0 = sizeof hit struct ptr
                b GetExtHit_Comparison
                GetExtHit_Loop:
                    add r5, r5, r0 # point to next hit struct
                    addi r3, r3, {sizeof(SpecialHit)} # point to next ExtHit struct
                    GetExtHit_Comparison:
                        cmplw r5, r4 # hit struct ptr != given hit struct ptr
                        bdnzf eq, GetExtHit_Loop
            # if we found our SpecialHit struct, exit
            beq Exit
            # otherwise, check to see if we have any new hitboxes to look for
            lwz r5, 0x14(sp) # number of new hitboxes to account for
            cmplwi r5, 0
            beq Invalid
            mtctr r5 # set loop count
            # reset number of new hitboxes count
            li r5, 0
            stw r5, 0x14(sp)
            # find the ExtHit using new Hit offset
            lwz r5, 0x10(sp)
            b GetExtHit_Loop

            Invalid:
                li r3, 0

            Exit:
                addi sp, sp, 0x18
                blr

            OriginalExit:
                lwz r31, 0x002C(r3)
        
        # Standalone function for handling stretched hitboxes for both fighters & items
        patchInsertAsm "801510ec":
            cmpwi r4, 343
            %`beq-`(OriginalExit)

            # inputs
            # r3 = ft/it gobj
            # r4 = ft/it hit struct

            # prolog
            mflr r0
            stw r0, 0x4(sp)
            stwu sp, -0x30(sp)
            stw r31, 0x2C(sp)
            stw r30, 0x28(sp)

            mr r31, r4 # hit struct
            mr r30, r3 # gobj

            # get ext hit struct
            %branchLink("0x801510d4") # getExtHit
            cmplwi r3, 0
            beq Exit
            # check stretch property
            lbz r3, {extHitOff(hitFlags)}(r3) # get flags
            %`rlwinm.`(r3, r3, 0, 27, 27) # check if Stretch property is set to true (0x10)
            beq Exit

            lhz r0, 0(r30)
            cmplwi r0, 0x4
            beq SetForFighter
            cmplwi r0, 0x6
            bne GetInitialPos

            # setup for item
            mr r3, r30
            %branchLink("0x80275788")
            b GetInitialPos

            SetForFighter:
                li r0, 2 # TODO should this be 4?
                stw r0, 0(r31)

            # 0xC(sp) = initial world pos x, y, z
            # 0x18(sp) = position with offset
            GetInitialPos:
                # first, get initial position with offset of 0
                lwz r3, 0x48(r31) # bone jobj
                li r4, 0 # offset ptr
                addi r5, sp, 0xC # result
                %branchLink("0x8000B1CC") # JObj_GetWorldPos
            
            # next, get position WITH offset
            lwz r3, 0x10(r31)
            lwz r4, 0x14(r31)
            stw r3, 0x18(sp) # store x
            stw r4, 0x1C(sp) # store y
            lwz r4, 0x18(r31)
            stw r4, 0x20(sp) # store z
            lwz r3, 0x48(r31) # bone jobj
            addi r4, sp, 0x18 # offset ptr
            addi r5, sp, 0x18
            %branchLink("0x8000B1CC") # JObj_GetWorldPos

            # now finally call the interop func
            addi r4, sp, 0xC
            addi r5, sp, 0x18
            mr r6, r31
            %branchLink("0x80275830")

            Exit:
                # epilog
                lwz r0, 0x34(sp)
                lwz r31, 0x2C(sp)
                lwz r30, 0x28(sp)
                addi sp, sp, 0x30
                mtlr r0
                blr

            OriginalExit:
                li r5, 0
            
        # Hitbox_UpdateHitboxPositions Stretch Patch 0x802f05a8
        patchInsertAsm "8007ad2c":
            # r3 = ft data
            # r4 = ft hit struct
            # r31 = ft hit struct
            lwz r0, 0(r31) # orig code line (changed from r4 to r31)
            cmpwi r0, 0 # hitbox to update is inactive, don't bother getting ExtHit
            beq Exit

            stw r3, 0x1C(sp) # backup ft/it data
            lwz r3, 0(r3) # gobj
            %branchLink("0x801510ec")
            lwz r3, 0x1C(sp) # restore ft/it data

            Exit:
                lwz r0, 0(r31)

        # Item_UpdateHitboxPositions Stretch Patch 0x802f05a8
        patchInsertAsm "802713a4":
            # r27 = itgobj
            # r30 = it data?
            # r29 = it hit struct
            lwz r0, 0(r29)
            cmpwi r0, 0 # hitbox to update is inactive, don't bother getting ExtHit
            beq Exit

            mr r3, r27 # gobj
            mr r4, r29 # ithit
            %branchLink("0x801510ec")

            Exit:
                lwz r0, 0(r29)
        
        # Function for Resetting Temp Gravity and Fall Speed
        patchInsertAsm "801510e8":
            cmpwi r4, 343
            %`beq-`(OriginalExit)
            # inputs
            # r3 = fighter data
            mflr r0
            stw r0, 0x4(sp)
            stwu sp, -0x38(sp)
            stw r31, 0x1C(sp)
            # r31 = fighter data
            mr r31, r3

            # first, reset gravity and fall speed to original attributes
            lwz r3, 0x10C(r3) # FtData
            lwz r3, 0(r3) # ptr to common attributes
            # reset gravity
            lfs f0, 0x5C(r3)
            stfs f0, 0x16C(r31)
            # reset fall speed
            lfs f0, 0x60(r3)
            stfs f0, 0x170(r31)

            # reset temp flag to 0
            li r3, 0
            lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r31)
            rlwimi r0, r3, 1, {flag(ffSetWeight)}
            stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r31)

            # now restore other modifiers to gravity + fall speed

            # Scale Check - Super/Posion Mushroom Attribute Changes for Gravity + Fall Speed
            lfs f0, -0x6A7C(rtoc) # 1.0
            lfs f1, 0x38(r31) # scale y
            fcmpu cr0, f0, f1
            beq CheckOtherModifiers

            # calculate gravity for scale
            addi r4, r31, 0x16C
            li r3, 0x30
            bl CalculateForScale

            # calculate fall speed for scale
            addi r4, r31, 0x170
            li r3, 0x34
            bl CalculateForScale

            # other modifiers such as bunny hoods, metal box & low gravity mode
            CheckOtherModifiers:

                BunnyHoodCheck:
                    lwz r0, 0x197C(r31) # wearing bunny hood?
                    cmplwi r0, 0
                    beq MetalBoxCheck
                    lwz r3, -0x5180(r13)
                    
                    lfs f1, 0x016C(r31)
                    lfs f0, 0x0020(r3)
                    fmuls f0, f1, f0
                    stfs f0, 0x016C(r31)

                    lfs f1, 0x0170(r31)
                    lfs f0, 0x0024(r3)
                    fmuls f0, f1, f0
                    stfs f0, 0x0170(r31)

                MetalBoxCheck:
                    lbz r0, 0x2223(r31)
                    %`rlwinm.`(r0, r0, 0, 31, 31) # 0x1, wearing metal box?
                    beq LowGravityCheck
                    lwz r3, -0x5184(r13)

                    lfs f1, 0x016C(r31)
                    lfs f0, 0xC(r3)
                    fmuls f0, f1, f0
                    stfs f0, 0x016C(r31)

                    lfs f1, 0x0170(r31)
                    lfs f0, 0x10(r3)
                    fmuls f0, f1, f0
                    stfs f0, 0x0170(r31)

                LowGravityCheck:
                    lbz r0, 0x2229(r31)
                    %`rlwinm.`(r0, r0, 26, 31, 31) # 0x40, low gravity mode?
                    beq Epilog
                    lwz r3, -0x5188(r13)

                    lfs f1, 0x016C(r31)
                    lfs f0, 0(r3)
                    fmuls f0, f1, f0
                    stfs f0, 0x016C(r31)

            Epilog:
                lwz r0, 0x3C(sp)
                lwz r31, 0x1C(sp)
                addi sp, sp, 0x38
                mtlr r0
                blr

            CalculateForScale:
                # inputs
                # r4 = fighterdata current attr ptr
                # r3 = scale multi offset
                # using
                # r31 = fighter data
                # f3 = current atr
                # f1 = multi
                # f2 = scale y
                lwz r0, -0x517C(r13)
                lfsx f1, r3, r0 # scale multi
                lfs f2, 0x38(r31) # scale y
                lfs f3, 0(r4) # current attr val
                
                lbl_800CFBF0:
                    lfs f0, -0x6A80(rtoc)
                    fcmpu cr0,f0,f1
                    bne lbl_800CFC00
                    b lbl_800CFC58
                lbl_800CFC00: 
                    fcmpo cr0,f1,f0
                    bge lbl_800CFC20
                    CallUnkFunc:
                        # backup LR & f3
                        mflr r0
                        stw r0, 0x18(sp)
                        stfd f3, 0x30(sp)
                        fneg f3,f1
                        lfs f1, -0x6A7C(rtoc)
                        %branchLink("0x800CF594") # r4 doesn't get messed with, no need to save
                        lfd f3, 0x30(sp)
                        fdivs f3,f3,f1
                        lwz r0, 0x18(sp)
                        mtlr r0
                        b lbl_800CFC58
                lbl_800CFC20: 
                    lfs f0, -0x6A7C(rtoc)
                    fcmpo cr0,f2,f0
                    cror 2, 1, 2
                    beq lbl_800CFC3C
                    fcmpo cr0,f1,f0
                    cror 2, 0, 2
                    bne lbl_800CFC50
                lbl_800CFC3C: 
                    lfs f0, -0x6A7C(rtoc)
                    fsubs f0,f2,f0
                    fmuls f0,f0,f3
                    fmadds f3,f1,f0,f3
                    b lbl_800CFC58

                lbl_800CFC50: 
                    fmuls f0,f3,f2
                    fdivs f3,f0,f1

                lbl_800CFC58: 
                    stfs f3, 0(r4)
                    blr

            OriginalExit:
                lwz r30, 0x4(r5)

        # Player_ReapplyAttributes Reset Variables
        patchInsertAsm "800d108c":
            # r30 = fighter data
            li r3, 0
            lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
            rlwimi r0, r3, 1, {flag(ffSetWeight)}
            stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
            lwz r3, 0x10C(r30) # original code line

        # Reset Temp Gravity & Fall Speed At 10 Frames After Launch
        patchInsertAsm "8006ab10":
            # r31 = fighter data
            lwz r3, 0x18AC(r31) # time_since_hit in frames
            cmpwi r3, 10
            blt Exit

            lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r31)
            %`rlwinm.`(r0, r0, 0, flag(ffSetWeight))
            beq Exit

            mr r3, r31
            %branchLink(CustomFuncResetGravityAndFallSpeed)
            lwz r3, 0x18AC(r31)
            Exit:
                %emptyBlock

        # patchInsertAsm "801510d8":
        #     cmpwi r4, 343
        #     %`beq-`(OriginalExit)

        #     # inputs
        #     # r3 = attacker gobj
        #     # r4 = attacker hit struct
        #     # r25 = defender data
        #     %backup

        #     %branchLink("0x801510D4")

        #     Exit:
        #         %restore
        #         blr

        #     OriginalExit:
        #         lfs f1, -0x5B40(rtoc)

        # CalculateKnockback Patch Beginning
        # Set 0x90(sp) to 0 - This is later used for storing our calculated ExtHit
        patchInsertAsm "8007a0ec":
            # r24 = 0
            stw r24, 0x90(sp)
            lis r29, 0x4330 # orig code

        # CalculateKnockback Patch Precalculation
        # Called when defender is attacked by another fighter
        patchInsertAsm "8007a14c":
            # r25 = defender data
            # r17 = hit struct?
            # r15 = attacker data
            # r27 = current char attr
            lwz r3, 0(r15)
            mr r4, r17 # hit struct
            %branchLink("0x801510d4")
            cmplwi r3, 0
            lfs f4, 0x88(r27) # weight of defender
            beq Exit
            mr r18, r3 # save ExtHit in r18 for other patches to use. NOTE: 8007a784 r18 gets replaced!
            # r3 contains ExtHit offset
            stw r3, 0x90(sp) # store for later use in the CalculateKnockback function

            StoreWindboxFlag:
                lbz r4, {extHitOff(hitFlags)}(r18)
                %`rlwinm.`(r4, r4, 0, flag(hfFlinchless)) # 0x8 for windbox flag
                li r3, 0
                beq WindboxSet
                li r3, 1
                WindboxSet:
                    lbz r4, {extFtDataOff(HeaderInfo, fighterFlags)}(r25)
                    rlwimi r4, r3, 0, {flag(ffHitByFlinchless)}
                    stb r4, {extFtDataOff(HeaderInfo, fighterFlags)}(r25)

            lbz r4, {extHitOff(hitFlags)}(r18)
            %`rlwinm.`(r4, r4, 0, flag(hfSetWeight)) # check 0x80
            beq Exit

            UseSetWeight:
                # if the 'Set Weight' flag is set, use a weight of 100 for the defender
                lwz r3, -0x514C(r13)
                lfs f4, 0x10C(r3) # uses same weight value from throws (100)
            Exit:
                %emptyBlock

        # CalculateKnockback Patch Precalculation
        # Called when defender is attacked by an item
        patchInsertAsm "8007a270":
            # r25 = def data, is fighter
            # r15 = fighter attacker gobj
            lwz r3, 0x8(r19) # get item gobj attacker
            lwz r4, 0xC(r19) # get last hit
            %branchLink("0x801510d4")
            cmplwi r3, 0
            lfs f22, 0x88(r27) # weight of defender
            beq Exit
            mr r18, r3 # save ExtHit in r18 for other patches to use. NOTE: 8007a784 r18 gets replaced!
            # r3 contains ExtHit offset
            stw r3, 0x90(sp) # store for later use in the CalculateKnockback function

            StoreWindboxFlag:
                lbz r4, {extHitOff(hitFlags)}(r18)
                %`rlwinm.`(r4, r4, 0, flag(hfFlinchless)) # 0x8 for windbox flag
                li r3, 0
                beq WindboxSet
                li r3, 1
                WindboxSet:
                    lbz r4, {extFtDataOff(HeaderInfo, fighterFlags)}(r25)
                    rlwimi r4, r3, 0, {flag(ffHitByFlinchless)}
                    stb r4, {extFtDataOff(HeaderInfo, fighterFlags)}(r25)

            lbz r4, {extHitOff(hitFlags)}(r18)
            %`rlwinm.`(r4, r4, 0, flag(hfSetWeight)) # check 0x80
            beq Exit

            UseSetWeight:
                # if the 'Set Weight' flag is set, use a weight of 100 for the defender
                lwz r3, -0x514C(r13)
                lfs f22, 0x10C(r3) # uses same weight value from throws (100)

            Exit:
                %emptyBlock

        # Hitbox_ItemLogicOnPlayer Patch for Skipping On Hit GFX for Windboxes
        # Called when fighter defender is attacked by another fighter
        patchInsertAsm "80078538":
            # actually this patch works for fighter on fighter
            # doesn't have to be item on player
            lwz r3, 0x2C(r3)
            lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r3)
            %`rlwinm.`(r0, r0, 0, flag(ffHitByFlinchless))
            beq OriginalExit # not flinchless, show GFX
            blr
            OriginalExit:
                lwz r3, 0(r3) # restore r3
                mflr r0 # orig code line

        # CalculateKnockback patch for setting hit variables that affect the defender and attacker after all calculations are done
        patchInsertAsm "8007aaf4":
            # 0x90 of sp contains calculated ExtHit
            # r12 = source ftdata
            # r25 = defender ftdata
            # r31 = ptr ft hit
            # r30 = gobj of defender
            # r4 = gobj of src
            # original: check if hit element is electric and if it is, set the hitlag multiplier of the defender to 1.5x
            # this part is here as a failsafe if the SetVars function below somehow returns early due to invalid data
            lwz r0, 0x1C(r31)
            cmplwi r0, 2
            bne SetVars
            lwz r3, -0x514C(r13)
            lfs f0, 0x1A4(r3)
            stfs f0, 0x1960(r25)
            SetVars:
                lwz r3, 0x8(r19)
                mr r4, r30
                lwz r5, 0xC(r19) # ptr fthit of source
                lwz r6, 0x90(sp)
                %branchLink("0x801510dc") # TODO const...
            li r0, 0 # skip the setting of electric hitlag multiplier

        # Hitbox Entity Vs Melee - Set Variables
        patchInsertAsm "802705ac":
            # eg. when a player hits an item with melee
            # r30 = itdata
            # r26 = fthit
            # r28 = attacker data ptr
            # r24 = gobj of itdata
            # r29 = gobj of attacker
            mr r3, r29 # src
            mr r4, r24 # def
            mr r5, r26 # ithit
            li r6, 0
            %branchLink("0x801510dc")
            Exit:
                lwz r0, 0xCA0(r30) # original code line

        # 8026fe68 - proj vs proj 
        # Hitbox Entity Vs Projectiles - Set Variables
        patchInsertAsm "80270bb8":
            # eg. when a player hits an item (eg. goomba) with projectile
            # r31 = itdata
            # r19 = hit struct
            # r26 = gobj of defender
            # r30 = gobj of attacker
            mr r3, r30 # atk
            mr r4, r26 # def
            mr r5, r19 # ithit
            li r6, 0
            %branchLink("0x801510dc")
            Exit:
                lwz r0, 0xCA0(r31) # original code line

        # ASDI multiplier mechanics patch
        patchInsertAsm "8008e7a4":
            # ASDI distance is increased or decreased based on multiplier
            # r31 = fighter data
            # f2 = 3.0 multiplier
            # f0 = free to use
            lfs f0, {extFtDataOff(HeaderInfo, sdiMultiplier)}(r31)
            fmuls f2, f2, f0 # 3.0 * our custom sdi multiplier
            lfs f0, 0x63C(r31) # original code line

        # ASDI multiplier mechanics patch 2
        patchInsertAsm "8008e7c0":
            # ASDI distance is increased or decreased based on multiplier
            # r31 = fighter data
            # f2 = 3.0 multiplier
            # f0 = free to use
            lfs f0, {extFtDataOff(HeaderInfo, sdiMultiplier)}(r31)
            fmuls f2, f2, f0 # 3.0 * our custom sdi multiplier
            lfs f0, 0x624(r31) # original code line

        # SDI multiplier mechanics patch
        patchInsertAsm "8008e558":
            # SDI distance is increased or decreased based on multiplier
            # r3 = fighter data
            # f4 = 6.0 multiplier
            lfs f0, {extFtDataOff(HeaderInfo, sdiMultiplier)}(r3)
            fmuls f4, f4, f0 # 6.0 * our custom sdi multiplier
            li r0, 254 # original code line

        # Hitstun mechanics patch
        patchInsertAsm "8008dd70":
            # Adds or removes frames of hitstun
            # 8008dd68: loads global hitstun multiplier of 0.4 from plco
            # f30 = calculated hitstun after multipling by 0.4
            # r29 = fighter data
            # f0 = free
            lfs f0, {extFtDataOff(HeaderInfo, hitstunModifier)}(r29) # load modifier
            fadds f30, f30, f0 # hitstun + modifier
            fctiwz f0, f30 # original code line

        # Shieldstun multiplier mechanics patch
        patchInsertAsm "8009304c":
            # note: yoshi's shield isn't affected... let's keep his shield unique
            # Shieldstun for defender is increased or decreased based on multiplier
            # f4 = 1.5
            # f0 is free here
            # r31 = fighter data
            lfs f0, {extFtDataOff(HeaderInfo, shieldstunMultiplier)}(r31) # load modifier
            fmuls f4, f4, f0 # 1.5 * our multiplier
            fsubs f2, f2, f3 # orig code line

        # PlayerThink_Shield/Damage Patch - Apply Hitlag on Thrown Opponents
        patchInsertAsm "8006d6e0":
            # r30 = fighter data
            lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
            %`rlwinm.`(r0, r0, 0, flag(ffForceHitlagOnThrown))
            beq OriginalExit
            lwz r29, 0x183C(r30) # thrown damage applied
            OriginalExit:
                mr r3, r30 # orig code line

        # Throw_ThrowVictim Patch - Set ExtHit Vars & Hitlag on Thrown Victim
        patchInsertAsm "800ddf88":
            # r25 = always grabbed victim's gobj
            # r24 = grabber source gobj
            # r30 = always victim's fighter data
            # r31 = source's fighter data
            mr r3, r24
            mr r4, r25
            addi r5, r31, 0xDF4 # source throw hitbox
            addi r6, r31, {extFtDataOff(HeaderInfo, specialThrowHit)}
            %branchLink("0x801510dc")

            # do hitlag vibration
            lfs f1, 0x1960(r30) # victim's hitlag multiplier
            mr r3, r30
            lwz r4, 0xE24(r28) # hitbox attribute
            lwz r5, 0xDFC(r28) # hitbox dmg
            lwz r6, 0x10(r30) # state id of victim
            %branchLink("0x80090594") # hitlag calculate

            # check if there are hitlag vibration frames
            # if there is vibration, the thrown victim should experience hitlag
            lhz r0, 0x18FA(r30) # model shift frames
            cmplwi r0, 0
            beq Exit

            # enable flag that forces hitlag for the thrown victim
            li r3, 1
            lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
            rlwimi r0, r3, 3, {flag(ffForceHitlagOnThrown)}
            stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
            
            Exit:
                lbz r0, 0x2226(r27) # orig code line

        # Custom Non-Standalone Function For Handling Setting the Appropriate Hitlag & Hitstun & SDI Multipliers
        patchInsertAsm "801510dc":
            cmpwi r4, 343
            %`beq-`(OriginalExit)

            # both items and fighters can experience hitlag
            # only defender fighter experience SDI & Hitstun mods

            # inputs
            # r3 = source gobj
            # r4 = defender gobj
            # r5 = source hit ft/it hit struct ptr
            # r6 = optional calculated ExtHit
            # source cannot be a null ptr
            cmplwi r3, 0
            beq EpilogReturn

            %backup
            # backup regs
            # r31 = source data
            # r30 = defender data
            # r29 = r5 ft/it hit
            # r28 = ExtHit offset
            # r27 = r3 source gobj
            # r26 = r4 defender gobj

            lwz r31, 0x2C(r3)
            lwz r30, 0x2C(r4)
            mr r29, r5
            mr r27, r3
            mr r26, r4

            # if ExtHit was already given to us, don't calculate ExtHit again
            cmplwi r6, 0
            mr r28, r6
            bne CalculateTypes

            # calculate ExtHit offset for given ft/it hit ptr
            CalculateExtHitOffset:
                mr r3, r27
                mr r4, r29
                %branchLink("0x801510d4")
            # r3 now has offset
            cmplwi r3, 0
            beq Epilog
            mr r28, r3 # ExtHit off

            CalculateTypes:
                # r25 = source type
                # r24 = defender type
                mr r3, r27
                bl IsItemOrFighter
                cmplwi r3, 0
                beq Epilog
                mr r25, r3 # backup source type

                mr r3, r26
                bl IsItemOrFighter
                cmplwi r3, 0
                beq Epilog
                mr r24, r3 # backup def type

            StoreHitlag:
                lfs f0, {extHitOff(hitlagMultiplier)}(r28) # load hitlag mutliplier

                # store hitlag multi for attacker depending on entity type
                cmpwi r25, 1
                addi r3, r31, {extItDataOff(HeaderInfo, hitlagMultiplier)}
                bne StoreHitlagMultiForAttacker
                addi r3, r31, 0x1960
                
                StoreHitlagMultiForAttacker:
                    stfs f0, 0(r3)

                # store hitlag multi for defender depending on entity type                
                cmpwi r24, 1
                addi r3, r30, {extItDataOff(HeaderInfo, hitlagMultiplier)}
                bne ElectricHitlagCalculate
                addi r3, r30, 0x1960

                # defenders can experience 1.5x more hitlag if hit by an electric attack
                ElectricHitlagCalculate:
                    lwz r0, 0x30(r29) # dmg hit attribute
                    cmplwi r0, 2 # electric
                    %`bne+`(StoreHitlagMultiForDefender) # not electric, just store the orig multiplier
                    # Electric
                    lwz r4, -0x514C(r13) # PlCo values
                    lfs f1, 0x1A4(r4) # 1.5 electric hitlag multiplier
                    fmuls f0, f1, f0 # 1.5 * multiplier
                    # store extra hitlag for DEFENDER ONLY in Melee

                StoreHitlagMultiForDefender:
                    stfs f0, 0(r3)

            # now we store other variables for defenders who are fighters ONLY
            cmpwi r24, 1 # fighter
            bne Epilog # not fighter, skip this section      

            StoreHitstunModifier:
                lfs f0, {extHitOff(hitstunModifier)}(r28)
                stfs f0, {extFtDataOff(HeaderInfo, hitstunModifier)}(r30)
                
            StoreSDIMultiplier:
                lfs f0, {extHitOff(sdiMultiplier)}(r28)
                stfs f0, {extFtDataOff(HeaderInfo, sdiMultiplier)}(r30)
            
            CalculateFlippyDirection:
                # TODO flippy for items such as goombas??
                lbz r3, {extHitOff(hitFlags)}(r28)
                lfs f0, 0x2C(r31) # facing direction of attacker
                %`rlwinm.`(r0, r3, 0, 26, 26) # check FlippyTypeForward
                bne FlippyForward
                %`rlwinm.`(r0, r3, 0, 25, 25) # check opposite flippy
                bne StoreCalculatedDirection
                li r0, 0
                stw r0, {extFtDataOff(HeaderInfo, lastHitPtr)}(r30)
                stw r0, {extFtDataOff(HeaderInfo, lastHitX)}(r30)
                stw r0, {extFtDataOff(HeaderInfo, lastHitY)}(r30)
                stw r0, {extFtDataOff(HeaderInfo, lastHitZ)}(r30)

                b SetWeight
                FlippyForward:
                    fneg f0, f0
                StoreCalculatedDirection:
                    stw r29, {extFtDataOff(HeaderInfo, lastHitPtr)}(r30)
                    lfs f0, 0x4C(r29)
                    stfs f0, {extFtDataOff(HeaderInfo, lastHitX)}(r30)
                    lfs f0, 0x50(r29)
                    stfs f0, {extFtDataOff(HeaderInfo, lastHitY)}(r30)
                    lfs f0, 0x54(r29)
                    stfs f0, {extFtDataOff(HeaderInfo, lastHitZ)}(r30)


            SetWeight:
                # handles the setting and reseting of temp gravity & fall speed
                lbz r3, {extHitOff(hitFlags)}(r28)
                %`rlwinm.`(r3, r3, 0, flag(hfSetWeight))
                beq ResetTempGravityFallSpeed # hit isn't set weight, check to reset vars

                SetTempGravityFallSpeed:
                    # hit is set weight, set temp vars
                    bl Constants
                    mflr r3
                    addi r4, r30, 0x110 # ptr attributes of defender
                    # set gravity
                    lfs f0, 0(r3)
                    stfs f0, 0x5C(r4)
                    # set fall speed
                    lfs f0, 4(r3)
                    stfs f0, 0x60(r4)
                    # set our temp gravity and fall speed flag to true
                    li r3, 1
                    lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
                    rlwimi r0, r3, 1, {flag(ffSetWeight)}
                    stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
                    b StoreDisableMeteorCancel

                ResetTempGravityFallSpeed:
                    # reset gravity and fall speed only if the temp flag is true
                    lbz r3, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
                    %`rlwinm.`(r3, r3, 0, flag(ffSetWeight))
                    beq StoreDisableMeteorCancel
                    # call custom reset func
                    mr r3, r30
                    %branchLink(CustomFuncResetGravityAndFallSpeed)
    
            StoreDisableMeteorCancel:
                lbz r3, {extHitOff(hitFlags)}(r28)
                %`rlwinm.`(r0, r3, 0, flag(hfNoMeteorCancel))
                li r3, 0
                beq MeteorCancelSet
                li r3, 1
                MeteorCancelSet:
                    lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
                    rlwimi r0, r3, 2, {flag(ffDisableMeteorCancel)}
                    stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)

            Epilog:
                %restore
                EpilogReturn:
                    blr

            IsItemOrFighter:
                # input = gobj in r3
                # returns 0 = ?, 1 = fighter, 2 = item, in r3
                lhz r0, 0(r3)
                cmplwi r0,0x4
                li r3, 1
                beq Result
                li r3, 2
                cmplwi r0,0x6
                beq Result
                li r3, 0
                Result:
                    blr

            Constants:
                blrl
                %`.float`(0.095) # mario's gravity
                %`.float`(1.7) # mario's fall speed

            OriginalExit:
                lwz r5, 0x010C(r31)

        # Patch PlayerThink_Shield/Damage Calculate Hitlag
        # If calculated hitlag is < 1.0, skip going into hitlag which disables A/S/DI
        patchInsertAsm "8006d708":
            lfs f0, -0x7790(rtoc) # 1.0
            fcmpo cr0, f1, f0
            %`bge+`(OriginalExit)
            # TODO add checks if callbacks are for SDI & ASDI functions?
            # we set the callback ptrs to 0 because it's possible for an attacker who is stuck in hitlag from attacking something
            # to be able to A/S/DI. In vBrawl, attackers hit by a move that does 0 hitlag does not reset their initial freeze frames but allows for only DI
            li r3, 0
            stw r3, 0x21D0(r30) # hitlag frame-per-frame cb
            stw r3, 0x21D8(r30) # hitlag exit cb
            %branch("0x8006d7e0") # skip set hitlag functions
            OriginalExit:
                stfs f1, 0x195C(r30)

        # Patch Damage_BranchToDamageHandler Calculate Hitlag for Pummels/Throw Related
        # If calculated hitlag is < 1.0, skip going into hitlag
        patchInsertAsm "8008f030":
            lfs f0, -0x7790(rtoc) # 1.0
            fcmpo cr0, f1, f0
            %`bge+`(OriginalExit)
            %branch("0x8008f078") # skip set hitlag functions
            OriginalExit:
                stfs f1, 0x195C(r27)            

        # Hitbox_MeleeLogicOnShield - Set Hit Vars
        patchInsertAsm "80076dec":
            # r31 = defender data
            # r30 = hit struct
            # r29 = src data
            # free regs to use: r0, f1, f0
            # get ExtHit
            lwz r3, 0(r29) # src gobj
            mr r4, r30 # hit struct
            %branchLink("0x801510d4")
            cmplwi r3, 0
            beq Exit

            # r3 = exthit
            lfs f0, {extHitOff(shieldstunMultiplier)}(r3)
            stfs f0, {extFtDataOff(HeaderInfo, shieldstunMultiplier)}(r31)

            Exit:
                # restore r3
                lwz r3, 0x24(sp)
                lwz r0, 0x30(r30) # original code line

        # Hitbox_ProjectileLogicOnShield - Set Hit Vars
        patchInsertAsm "80077914":
            # r29 = defender data
            # r28 = hit struct
            # r27 = src data
            # free regs to use f1, f0
            lwz r3, 0x4(r27) # src gobj
            mr r4, r28 # hit struct
            %branchLink("0x801510d4")
            cmplwi r3, 0
            beq Exit

            # r3 = exthit
            lfs f0, {extHitOff(shieldstunMultiplier)}(r3)
            stfs f0, {extFtDataOff(HeaderInfo, shieldstunMultiplier)}(r29)

            Exit:
                lwz r0, 0x30(r28) # original code line
        
        # COMMENTED OUT BELOW ARE CODES RELATING TO 0% HITLAG AGAINST SHIELDING OPPONENTS
        # # SHIELD HIT - Character Hitbox - Attacker+Victim
        # patchInsertAsm "80076d58":
        #     # patch for completely skipping hitlag functions (ASDI, DI & SDI) if hitlag multiplier is 0%
        #     # r31 = defender data
        #     # r30 = hit struct
        #     # r29 = src data
        #     # r3 has to be 0 to skip hitlag functions
        #     mr r0, r3 # backup r3

        #     # get ExtHit
        #     mr r3, r29 # src data
        #     mr r4, r30 # hit struct
        #     li r5, 2324
        #     li r6, 312
        #     li r7, {ExtFighterDataOffset}
        #     %branchLink("0x801510d8")
        #     cmplwi r3, 0
        #     beq Exit
        #     # r3 = ExtHit
        #     stw r3, 0x10(sp) # save ExtHit to stack for later use in other functions

        #     lwz r3, {extHitOff(hitlagMultiplier)}(r3) # load hitlag mutliplier
        #     cmpwi r3, 0
        #     mr r3, r0 # restore r3 here
        #     bne Exit
        #     li r3, 0

        #     Exit:
        #         lwz r0, 0x1924(r29) # orig line

        # # SHIELD HIT - Article Hitbox - Attacker+Victim Hitbox_ProjectileLogicOnShield
        # patchInsertAsm "80077718":
        #     # r29 = defender data
        #     # r28 = hit struct
        #     # r27 = src data
        #     # free regs to use f1, f0
        #     # patch for completely skipping hitlag functions (ASDI, DI & SDI) if hitlag multiplier is 0%
        #     # r31 has to be 0 to skip hitlag functions
        #     mr r3, r27 # src data
        #     mr r4, r28 # hit struct
        #     li r5, 1492
        #     li r6, {ItHitSize}
        #     li r7, {ExtItemDataOffset}
        #     %branchLink("0x801510d8")
        #     cmplwi r3, 0
        #     beq Exit
        #     # r3 = ExtHit
        #     stw r3, 0x20(sp) # save ExtHit to stack for later use in other functions

        #     lwz r0, {extHitOff(hitlagMultiplier)}(r3) # load hitlag mutliplier
        #     cmpwi r0, 0
        #     bne Exit
        #     li r31, 0

        #     Exit:
        #         lwz r0, 0x0C34(r27) # orig line

        # # Hitbox_MeleeLogicOnShield - Set Hit Vars
        # patchInsertAsm "80076dec":
        #     # r31 = defender data
        #     # r30 = hit struct
        #     # r29 = src data
        #     # free regs to use: r0, f1, f0
        #     mr r0, r3 # backup r3

        #     lwz r3, 0x10(sp) # load ExtHit from patch 80076d58
        #     cmplwi r3, 0
        #     beq Exit

        #     # r3 = exthit
        #     lfs f0, {extHitOff(shieldstunMultiplier)}(r3)
        #     stfs f0, {extFtDataOff(HeaderInfo, shieldstunMultiplier)}(r31)

        #     Exit:
        #         # restore r3
        #         mr r3, r0
        #         lwz r0, 0x30(r30) # original code line

        # # Hitbox_ProjectileLogicOnShield - Set Hit Vars
        # patchInsertAsm "80077918":
        #     # r29 = defender data
        #     # r28 = hit struct
        #     # r27 = src data
        #     # free regs to use f1, f0
        #     lwz r3, 0x20(sp) # load ExtHit from stack (patch 80077718)
        #     %branchLink("0x801510d8")
        #     cmpwi r3, 0
        #     beq Exit

        #     # r3 = exthit
        #     lfs f0, {extHitOff(shieldstunMultiplier)}(r3)
        #     stfs f0, {extFtDataOff(HeaderInfo, shieldstunMultiplier)}(r29)

        #     Exit:
        #         # restore r6
        #         mr r6, r30
        #         stw r0, 0x19B0(r29) # original code line

        # ItemThink_Shield/Damage Hitlag Function For Other Entities
        # Patch Hitlag Multiplier
        patchInsertAsm "8026b454":
            # patch hitlag function used by other entities
            # r31 = itdata
            # f0 = floored hitlag frames
            lfs f1, {extItDataOff(HeaderInfo, hitlagMultiplier)}(r31)
            fmuls f0, f0, f1 # calculated hitlag frames * multiplier
            fctiwz f0, f0

        # ItemThink_Shield/Damage After Hitlag Calculation
        # If calculated hitlag is < 1.0, skip going into hitlag
        patchInsertAsm "8026a5f8":
            lfs f0, -0x7790(rtoc) # 1.0
            fcmpo cr0, f1, f0
            %`bge+`(OriginalExit)
            %branchLink("0x8026a68c") # skip hitlag
            OriginalExit:
                lfs f0, 0xCBC(r31)

        # Reset Custom Variables for Items
        patchInsertAsm "80269cdc":
            # r5 = itdata

            # reset custom vars to 1.0
            lfs f0, -0x7790(rtoc) # 1.0            
            stfs f0, {extItDataOff(HeaderInfo, hitlagMultiplier)}(r5)

            # reset custom vars to 0.0
            lfs f0, -0x33A8(rtoc) # 0.0, original code line

        # Init Default Values for ExtHit - Projectiles
        # SubactionEvent_0x2C_HitboxProjectile_StoreInfoToDataOffset
        patchInsertAsm "802790fc":
            # r4 = hitbox id
            # r30 = item data??
            mulli r3, r4, {sizeof(SpecialHit)}
            addi r3, r3, {ExtItemDataOffset}
            add r3, r30, r3
            %branchLink(CustomFunctionInitDefaultEventVars)
            Exit:
                lwz r0, 0(r29) # orig code line

        # Init Default Values for ExtHit - Melee
        # SubactionEvent_0x2C_HitboxMelee_StoreInfoToDataOffset
        patchInsertAsm "80071288":
            # r0 = hitbox ID
            # r31 = fighter data
            mulli r3, r0, {sizeof(SpecialHit)}
            addi r3, r3, {ExtFighterDataOffset}
            add r3, r31, r3
            %branchLink(CustomFunctionInitDefaultEventVars)
            Exit:
                lwz r0, 0(r30) # orig code line

        # Init Default Values for ExtHit - Throws
        # SubactionEvent_0x88_Throw
        patchInsertAsm "80071e48":
            # r0 = hitbox ID
            # r6 = fighter data
            # only throws are supported, release hitboxes are not
            cmplwi r0, 1 # throw type = Release
            bge Exit
            # reset ExtHit vars
            addi r3, r6, {extFtDataOff(HeaderInfo, specialThrowHit)}
            %branchLink(CustomFunctionInitDefaultEventVars)
            # r3 still contains ExtHit
            # r0 contains 0
            # default hitlag multiplier for all throws is 0x
            stw r0, {extHitOff(hitlagMultiplier)}(r3)

            Exit:
                addi r3, r31, 0 # orig code line

        patchInsertAsm "8006be00":
            lwz r3, {extFtDataOff(HeaderInfo, lastHitPtr)}(r31)
            cmplwi r3, 0
            beq OriginalExit
            
            VortexKnockback:
                %backup

                lwz r0, 0x18AC(r31) # time_since_hit in frames
                cmpwi r0, 5
                
#                lfs f1, -0x778C(rtoc) # 0.0
#                lfs f2, -0x778C(rtoc) # 0.0
                lfs f1, 0x8C(r31)
                lfs f2, 0x90(r31)
                bge NoMoreTime

                bl DataBob
                mflr r5


                lwz r0, 0(r3)
                cmpwi r0, 0
                addi r4, r31, {extFtDataOff(HeaderInfo, lastHitX)} # pos of hitbox
                beq Bob
#                addi r4, r3, 0x4C # pos of hitbox
                Bob:
                    mr r3, r28 # gobj
                    lfs f1, 0x8(r5) # 
                    lfs f2, 0xC(r5)
                    bl ToPointFunc

                bl CalcAttackerMomentum
                b Epilog
                CalcAttackerMomentum:


                    lwz r4, 0x1868(r31)
                    lwz r4, 0x2C(r4)


                    lfs f3, 0x84(r4)
                    lfs f0, 0xB4(r4)
                    fadds f0, f0, f3

                    lfs f3, 0xB4(r4)
                    fsubs f0, f0, f3
                    fadds f2, f0, f2


                    lfs f3, 0x80(r4)
                    lfs f0, 0xB0(r4)
                    fadds f0, f0, f3

                    lfs f3, 0xB0(r4)
                    fsubs f0, f0, f3

                    fadds f1, f0, f1

                stfs f1, 0x8C(r31)
                stfs f2, 0x90(r31)
                blr
                #b Epilog

#[ f1 = speed stuff
   f2 = speed stuff
   r3 = our gobj
   r4 = vec pos of where to go ]#
            ToPointFunc:
                mflr r0
                stw r0, 4(r1)
                stwu r1, -0x58(r1)
                stfd f31, 0x50(r1)
                fmr f31, f2
                stfd f30, 0x48(r1)
                fmr f30, f1
                stfd f29, 0x40(r1)
                stw r31, 0x3c(r1)
                stw r30, 0x38(r1)
#                addi r30, r5, 0
                addi r5, r1, 0x2c
                lwz r31, 0x2c(r3)
                addi r3, r4, 0
                addi r4, r31, 0xb0
                %branchLink("0x8000D4F8")
                #bl func_8000D4F8
                lfs f1, 0x2c(r1)
                lfs f2, 0x30(r1)
                lfs f0, -0x3D60(rtoc) # 0.20

                fmuls f1, f1, f0
                fmuls f2, f2, f0

                lwz r0, 0x5c(r1)
                lfd f31, 0x50(r1)
                lfd f30, 0x48(r1)
                lfd f29, 0x40(r1)
                lwz r31, 0x3c(r1)
                lwz r30, 0x38(r1)
                addi r1, r1, 0x58
                mtlr r0
                blr
            
           
            Data:
                blrl
                %`.float`(0.20)
                %`.float`(0.12) # was 0.08
                %`.float`(0.50)
                %`.float`(10)
                %`.float`(80)

            DataBob:
                blrl
                %`.float`(0.48)
                %`.float`(0.235)
                %`.float`(0.16) # smoothTime
                %`.float`(100) # maxSpeed

                NoMoreTime:
                    li r0, 0
                    stw r0, {extFtDataOff(HeaderInfo, lastHitPtr)}(r31)
                    stw r0, {extFtDataOff(HeaderInfo, lastHitX)}(r31)
                    stw r0, {extFtDataOff(HeaderInfo, lastHitY)}(r31)
                    stw r0, {extFtDataOff(HeaderInfo, lastHitZ)}(r31)
                    bl CalcAttackerMomentum
                    lfs f0, -0x13BC(rtoc) # 3.0
                    fcmpo cr0, f2, f0
                    blt CheckNegative
                    # if >= 3
                    fmr f2, f0
                    b SetYVel

                    CheckNegative:
                        lfs f0, -0x7640(rtoc) # -1
                        fcmpo cr0, f2, f0
                        bge SetYVel
                        fmr f2, f0

                    SetYVel:
                        stfs f2, 0x90(r31) # store into kb_vel y 
        
                    lfs f0, -0x13BC(rtoc) # 3.0
                    fcmpo cr0, f1, f0
                    blt CheckNegativeX
                    # if >= 3
                    fmr f1, f0
                    b SetXVel

                    CheckNegativeX:
                        lfs f0, -0x36d8(rtoc) # -3
                        fcmpo cr0, f1, f0
                        bge SetXVel
                        fmr f1, f0

                    SetXVel:
                        stfs f1, 0x8C(r31) # store into kb_vel x

# meteor cancelling disabled
#[                     fmr f0, f2
                    fmr f2, f1
                    fmr f1, f0
                    %branchLink("0x80022c30") # atan2
                    lfs f0, -0x76c4(rtoc) # 180/pi. Convert radians to degrees
                    fmuls f1, f0, f1
                    fctiw f0, f1
                    stfd f0, -8(sp)
                    lwz r3, -4(sp)
                    cmpwi r3, 0 # force angle into [0, 360]
                    bge positive_angle # (so meteor cancelling works)
                    addi r3, r3, 360
                    positive_angle:
                        # check for meteor cancelling
                        li r0, 230
                        cmplw r0, r3
                        bgt Epilog
                        li r0, 310
                        cmplw r3, r0
                        bgt Epilog
                        # allow meteor cancelling
                        li r0, 1
                        stb r0, 0x235A(r31) # can meteor cancel
                        lwz r3, -0x514C(r13)
                        lwz r0, 0x7f0(r3) # window of 8 frames
                        stb r0, 0x235B(r31) # window ]#
                Epilog:
                    %restore

            OriginalExit:
                lwz r12, 0x21D0(r31) # orig code line



#[         # Reset Custom ExtFighterData vars that are involved at the end of Hitlag for Fighters
        patchInsertAsm "8006d1d8":
            # reset vars that need to be 1
            # r31 = fighter data
            lfs f0, -0x7790(rtoc) # 1
            stfs f0, {extFtDataOff(HeaderInfo, sdiMultiplier)}(r31)


            lwz r3, {extFtDataOff(HeaderInfo, lastHitPtr)}(r31)
            cmplwi r3, 0
            beq Exit

            stwu sp, -0x30(sp)
            # first calculate pos diff x between hitbox & defender
                
            lfs f1, 0x4C(r3) # hitbox x
            lfs f0, 0xB0(r31) # defender coll x
            fsubs f2, f1, f0 # diff x

            lfs f0, -0x3D60(rtoc) # calculate 20% of diff x
            fmuls f2, f2, f0
            stfs f2, 0x14(sp) # x

            lwz r4, 0x1868(r31)
            lwz r4, 0x2C(r4)

            # check if reverse hit
            lfs f1, 0xB0(r31) # defender x
            lfs f0, 0xB0(r4) # attacker x
            fsubs f1, f1, f0
            lfs f0, -0x7700(rtoc) # 0.0
            fcmpo cr0, f1, f0
            %`bge+` CalcDiffY
            # if reverse hit, negate the diff x
            fneg f2, f2
            CalcDiffY:
                lfs f1, 0x50(r3) # hitbox y
                lfs f0, 0xB4(r31) # defender coll y
                fsubs f1, f1, f0 # diff y
                lfs f0, -0x3D60(rtoc) # 20% of diff y
                fmuls f1, f1, f0 # diff y * 0.20
                stfs f1, 0x18(sp) # y

            bl Data
            mflr r5

            addi r4, r3, 0x4C # pos of hitbox
            lwz r3, 0(r31)
            lfs f1, 0(r5)
            lfs f2, 0x4(r5)
            bl ToPointFunc

            lwz r4, 0x1868(r31)
            lwz r4, 0x2C(r4)


            lfs f3, 0x84(r4)
            lfs f0, 0xB4(r4)
            fadds f0, f0, f3

            lfs f3, 0xB4(r4)
            fsubs f0, f0, f3


            fadds f2, f0, f2 # attacker y + 20% diffy
            lfs f0, -0x13BC(rtoc) # 3.0
            fcmpo cr0, f2, f0
            blt CheckNegative
            # if >= 3
            fmr f2, f0
            b SetYVel

            CheckNegative:
                lfs f0, -0x7640(rtoc) # -1
                fcmpo cr0, f2, f0
                bge SetYVel
                fmr f2, f0

            SetYVel:
                stfs f2, 0x90(r31) # store into kb_vel y 

            lfs f3, 0x80(r4)
            lfs f0, 0xB0(r4)
            fadds f0, f0, f3

            lfs f3, 0xB0(r4)
            fsubs f0, f0, f3

#            lfs f1, 0x14(sp)
            fadds f1, f0, f1 # attacker x + 20% diff x
            
            lfs f0, -0x13BC(rtoc) # 3.0
            fcmpo cr0, f1, f0
            blt CheckNegativeX
            # if >= 3
            fmr f1, f0
            b SetXVel

            CheckNegativeX:
                fneg f0, f0
                fcmpo cr0, f1, f0
                bge SetXVel
                fmr f1, f0

            SetXVel:
                stfs f1, 0x8C(r31) # store into kb_vel x

            li r0, 0
            stw r0, {extFtDataOff(HeaderInfo, lastHitPtr)}(r31)
            
            addi sp, sp, 0x30

            b Exit

#[ f1 = speed stuff
   f2 = speed stuff
   r3 = our gobj
   r4 = vec pos of where to go ]#
            ToPointFunc:
                mflr r0
                stw r0, 4(r1)
                stwu r1, -0x58(r1)
                stfd f31, 0x50(r1)
                fmr f31, f2
                stfd f30, 0x48(r1)
                fmr f30, f1
                stfd f29, 0x40(r1)
                stw r31, 0x3c(r1)
                stw r30, 0x38(r1)
#                addi r30, r5, 0
                addi r5, r1, 0x2c
                lwz r31, 0x2c(r3)
                addi r3, r4, 0
                addi r4, r31, 0xb0
                %branchLink("0x8000D4F8")
                #bl func_8000D4F8
                lfs f1, 0x2c(r1)
                lfs f0, 0x30(r1)
                fmuls f2, f1, f1
                lfs f3, 0x34(r1)
                fmuls f1, f0, f0
                lfs f0, -0x57E8(rtoc)
                fmuls f3, f3, f3
                fadds f1, f2, f1
                fadds f29, f3, f1
                fcmpo cr0, f29, f0
                ble lbl_8015BEF8
                frsqrte f1, f29
                lfd f3, -0x57D8(rtoc)
                lfd f2, -0x57D0(rtoc)
                fmul f0, f1, f1
                fmul f1, f3, f1
                fnmsub f0, f29, f0, f2
                fmul f1, f1, f0
                fmul f0, f1, f1
                fmul f1, f3, f1
                fnmsub f0, f29, f0, f2
                fmul f1, f1, f0
                fmul f0, f1, f1
                fmul f1, f3, f1
                fnmsub f0, f29, f0, f2
                fmul f0, f1, f0
                fmul f0, f29, f0
                frsp f0, f0
                stfs f0, 0x24(r1)
                lfs f29, 0x24(r1)
                lbl_8015BEF8:
                    fcmpo cr0, f29, f30
                    bge lbl_8015BF0C
                    b lbl_8015BF40
                lbl_8015BF0C:
#                    stfs f29, 0(r30)
                    addi r3, r1, 0x2c
                    %branchLink("0x8000D2EC")
#                    bl func_8000D2EC
                    fmuls f1, f29, f31
                    lfs f0, 0x2c(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x2c(r1)
                    lfs f0, 0x30(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x30(r1)
                    lfs f0, 0x34(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x34(r1)
                lbl_8015BF40:
                    lfs f1, 0x2c(r1)
#                    stfs f0, 0x8c(r31)
                    lfs f2, 0x30(r1)
#                    stfs f0, 0x90(r31)
                    lwz r0, 0x5c(r1)
                    lfd f31, 0x50(r1)
                    lfd f30, 0x48(r1)
                    lfd f29, 0x40(r1)
                    lwz r31, 0x3c(r1)
                    lwz r30, 0x38(r1)
                    addi r1, r1, 0x58
                    mtlr r0
                    blr
            Data:
                blrl
                %`.float`(0.20)
                %`.float`(0.12) # was 0.08
                %`.float`(0.50)
                %`.float`(10)
                %`.float`(80)

            Exit:
                lwz r0, 0x24(sp)
                

 ]#
        # Reset Custom ExtFighterData vars that are involved at the end of Hitlag for Fighters
        patchInsertAsm "8006d1d8":
            # reset vars that need to be 1
            # r31 = fighter data
            lfs f0, -0x7790(rtoc) # 1
            stfs f0, {extFtDataOff(HeaderInfo, sdiMultiplier)}(r31)
            Exit:
                lwz r0, 0x24(sp)

        # Fix for Hitlag multipliers not affecting hits within grabs
        # TODO what about for item related hitlag?
        patchInsertAsm "8006d95c":
            # reset multiplier ONLY when there isn't a grabbed_attacker ptr
            # r30 = fighter data
            lwz r0, 0x1A58(r30) # grab_attacker ptr
            cmplwi r0, 0
            bne Exit # if someone is grabbing us, don't reset the multiplier
            stfs f0, 0x1960(r30) # else reset it to 1.0
            Exit:
                %emptyBlock

        # Reset Custom ExtFighterData vars that are involved with PlayerThink_Shield/Damage
        patchInsertAsm "8006d8fc":
            # reset custom ExtData vars for fighter
            # f1 = 0.0
            # r3 = 0
            # r30 = fighter data
            # reset vars to 0
    
            # reset flinchless flag to 0
            lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
            rlwimi r0, r3, 0, {flag(ffHitByFlinchless)}
            stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)

            # reset disable meteor cancel flag to 0
            lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
            rlwimi r0, r3, 2, {flag(ffDisableMeteorCancel)}
            stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)

            # reset throw hitlag flag to 0
            lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
            rlwimi r0, r3, 3, {flag(ffForceHitlagOnThrown)}
            stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)

            # reset hitstun modifier to 0
            stfs f1, {extFtDataOff(HeaderInfo, hitstunModifier)}(r30)

            # reset vars to 1.0
            lfs f0, -0x7790(rtoc) # 1.0
            stfs f0, {extFtDataOff(HeaderInfo, shieldstunMultiplier)}(r30)

            Exit:
                stfs f1, 0x1838(r30) # original code line

        # Custom Non-Standalone Function For Initing Default Values in ExtHit
        patchInsertAsm "801510e4":
            # inputs
            # r3 = ExtHit
            # TODO samus create hitbox?
            cmpwi r4, 343
            %`beq-`(OriginalExit)

            # reset vars that need to be 1
            lfs f0, -0x7790(rtoc) # 1
            stfs f0, {extHitOff(hitlagMultiplier)}(r3)
            stfs f0, {extHitOff(sdiMultiplier)}(r3)
            stfs f0, {extHitOff(shieldstunMultiplier)}(r3)

            # reset vars that need to be 0
            lfs f0, -0x778C(rtoc) # 0.0
            stfs f0, {extHitOff(hitstunModifier)}(r3)
            li r0, 0
            stw r0, {extHitOff(hitFlags)}(r3)
            blr

            OriginalExit:
                lfs f2, -0x5B3C(rtoc) # orig code line

        # Custom Non-Standalone Function For Reading Subaction Event Data
        patchInsertAsm "801510e0":
            cmpwi r4, 343
            %`beq-`(OriginalExit)

            # inputs
            # r3 = ExtHit struct ptr
            # r4 = Hit struct ptr
            # r5 = ExtItem/FighterDataOffset
            # r6 = Hit struct offset
            # r7 = Hit struct size
            # r8 = New Hit Struct Offset
            # r30 = item/fighter data
            # r27 = item/fighter gobj
            mflr r0
            stw r0, 0x4(sp)
            stwu sp, -0x50(sp)

            lwz r9, 0x8(r29) # load current subaction ptr
            li r10, 0 # used for checking if we need to loop for all hitboxes

            cmplwi r4, 0
            bne BeginReadData

            CheckApplyToPrevious:
                lbz r0, 0x1(r9)
                %`rlwinm.`(r10, r0, 0, 27, 27) # 0x10, apply to all hitboxes 0-3
                rlwinm r3, r0, 27, 29, 31 # 0xE0 hitbox id/type
                beq CalculateHitStructs # if not set, just loop once
                # otherwise, apply the properties to the given hitbox id
                li r3, 0 # set starting id to 0

            CalculateHitStructs:
                # input:
                # r3 = hitbox id
                # calculate normal Hit struct ptr
                mullw r4, r3, r7
                cmplwi r3, {OldHitboxCount}
                blt CalcNormal
                add r4, r4, r8
                CalcNormal:
                    add r4, r4, r6
                    add r4, r30, r4                
                # calculate ExtHit ptr offset in Ft/It data
                mulli r3, r3, {sizeof(SpecialHit)}
                add r3, r3, r5
                add r3, r30, r3

            BeginReadData:
                # r3 = ExtHit ptr
                # r4 = Hit struct
                # load 0.01 to use for multipliying our multipliers
                lwz r5, -0x514C(r13) # static vars??
                lfs f1, 0xF4(r5) # load 0.01 into f1
                # hitlag & SDI multipliers
                lhz r5, 0x1(r9)
                rlwinm r5, r5, 0, 0xFFF # 0xFFF, load hitlag multiplier
                sth r5, 0x44(sp)
                lhz r5, 0x3(r9)
                rlwinm r5, r5, 28, 0xFFF # load SDI multiplier
                sth r5, 0x46(sp)
                psq_l f0, 0x44(sp), 0, 5 # load both hitlag & sdi multipliers into f0 (ps0 = hitlag multi, ps1 = sdi multi)
                ps_mul f0, f1, f0 # multiply both hitlag & sdi multipliers by f1 = 0.01
                psq_st f0, {extHitOff(hitlagMultiplier)}(r3), 0, 7 # store calculated hitlag & sdi multipliers next to each other

                # read shieldstun multiplier & hitstun modifier
                lwz r5, -0x514C(r13)
                psq_l f1, 0xF4(r5), 1, 7 # load 0.01 in f1(ps0), 1.0 in f1(ps1)
                lhz r5, 0x4(r9)
                rlwinm r5, r5, 0, 0xFFF # load shieldstun multiplier
                sth r5, 0x40(sp)
                lbz r5, 0x6(r9) # read hitstun modifier byte
                slwi r5, r5, 24
                srawi r5, r5, 24
                sth r5, 0x42(sp)
                psq_l f0, 0x40(sp), 0, 5 # load shieldstun multi in f0(ps0), hitstun mod in f0(ps1) ]#
                ps_mul f0, f1, f0 # shieldstun multi * 0.01, hitstun mod * 1.00
                psq_st f0, {extHitOff(shieldstunMultiplier)}(r3), 0, 7 # store results next to each other
                # read isSetWeight & Flippy bits & store it
                lbz r0, 0x7(r9)
                stb r0, {extHitOff(hitFlags)}(r3)
                bl SetBaseDamage

            # don't loop if apply to all hitboxes is not enabled
            cmplwi r10, 0
            beq Exit

            CopyToAllHitboxes:
                # r5 = ptr to next ExtHit
                # r4 = ptr to Ft/ItHit
                # r3 = ptr to old ExtHit
                # r10 = index loop counter
                li r10, 1 # hitbox id to 1
                addi r5, r3, {sizeof(SpecialHit)} # next ExtHit struct
                add r4, r4, r7 # next Ft/It Hit struct
                Loop:
                    cmpwi r10, 4
                    bne Body
                    add r4, r4, r8
                    Body:
                        lwz r0, {extHitOff(hitlagMultiplier)}(r3)
                        stw r0, {extHitOff(hitlagMultiplier)}(r5)

                        lwz r0, {extHitOff(sdiMultiplier)}(r3)
                        stw r0, {extHitOff(sdiMultiplier)}(r5)

                        lwz r0, {extHitOff(shieldstunMultiplier)}(r3)
                        stw r0, {extHitOff(shieldstunMultiplier)}(r5)

                        lwz r0, {extHitOff(hitstunModifier)}(r3)
                        stw r0, {extHitOff(hitstunModifier)}(r5)

                        lbz r0, {extHitOff(hitFlags)}(r3)
                        stb r0, {extHitOff(hitFlags)}(r5)
                        bl SetBaseDamage

                    addi r5, r5, {sizeof(SpecialHit)} # point to next ExtHit struct
                    add r4, r4, r7 # point to next Ft/It Hit struct
                    addi r10, r10, 1 # hitboxId++
                    cmplwi r10, {NewHitboxCount}
                    %`blt+`(Loop)

            Exit:
                # advance script
                addi r9, r9, 8 # TODO create a function to calculate this
                stw r9, 0x8(r29) # store current pointing ptr
                lwz r0, 0x54(sp)
                addi sp, sp, 0x50
                mtlr r0
                blr

            SetBaseDamage:
                # r0 = flags
                # r4 = ft/it hit
                %`rlwinm.`(r0, r0, 0, flag(hfNoStale))
                beq Return_SetStaling
                # if no staling == true, set Ft/It hit's damage_f to its base damage
                lwz r0, 0x8(r4)
                sth r0, 0x40(sp)
                psq_l f1, 0x40(sp), 1, 5
                stfs f1, 0xC(r4)
                Return_SetStaling:                
                    blr

            OriginalExit:
                fmr f3, f1

        # Patch for Subaction_FastForward
        patchInsertAsm "80073430":
            subi r0, r28, 10 # orig code line
            cmpwi r28, 0x3C # Hitbox Extension Custom ID
            bne OriginalExit
            lwz r4, 0x8(r29) # current action ptr
            addi r4, r4, 8
            stw r4, 0x8(r29)
            %branch("0x80073450")
            OriginalExit:
                %emptyBlock

        # Patch for FastForwardSubactionPointer2
        patchInsertAsm "80073574":
           # fixes a crash with Kirby when using inhale with a custom subaction event
            lwz r4, 0x8(r29) # orig code line, current action ptr
            cmpwi r28, 0x3C # Hitbox Extension Custom ID
            bne OriginalExit
            addi r4, r4, 8
            stw r4, 0x8(r29)
            %branch("0x80073588")
            OriginalExit:
                %emptyBlock

        # Custom Fighter Subaction Event
        patchInsertAsm "80073318":
            # use 0xF1 as code, make sure r28 == 0x3c
            # r27 = item/fighter gobj
            # r29 = script struct ptr
            # r30 = item/fighter data
            cmpwi r28, 0x3C
            %`bne+`(OriginalExit)

            # use throw hitbox if flag is set to true (only for players)
            lwz r3, 0x8(r29)
            lbz r3, 0x7(r3) # flags 1
            %`rlwinm.`(r3, r3, 0, flag(hfAffectOnlyThrow))
            li r3, 0
            li r4, 0
            beq ReadEvent
            addi r3, r30, {extFtDataOff(HeaderInfo, specialThrowHit)}
            addi r4, r30, 0xDF4
            ReadEvent:
                li r5, {ExtFighterDataOffset}
                li r6, 2324
                li r7, {FtHitSize}
                li r8, {extFtDataOff(HeaderInfo, newHits) - ((OldHitboxCount * FtHitSize) + 2324)}
                %branchLink(CustomFunctionReadEvent)
                %branch("0x8007332c")
            OriginalExit:
                lwz r12, 0(r3)

        # Custom Item Subaction Event
        patchInsertAsm "80279abc":
            # use 0xF1 as code, make sure r28 == 0x3c
            # r27 = item/fighter gobj
            # r29 = script struct ptr
            # r30 = item/fighter data
            cmpwi r28, 0x3C
            %`bne+`(OriginalExit)
            li r3, 0
            li r4, 0
            li r5, {ExtItemDataOffset}
            li r6, 1492
            li r7, {ItHitSize}
            li r8, {extItDataOff(HeaderInfo, newHits) - ((OldHitboxCount * ItHitSize) + 1492)}
            %branchLink(CustomFunctionReadEvent)
            %branch("0x80279ad0")
            OriginalExit:
                lwz r12, 0(r3)
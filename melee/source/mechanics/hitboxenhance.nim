import geckon

# TODO add m-ex support

# TODO properties to add: Set weight

const
    FighterDataOrigSize = 0x23EC
    ItemDataOrigSize = 0xFCC
    ExtFighterDataOffset = FighterDataOrigSize
    ExtItemDataOffset = ItemDataOrigSize

# Variable offsets in our new ExtHit struct
const
    ExtHitHitlagOffset = 0x0 # float
    ExtHitSDIMultiplierOffset = ExtHitHitlagOffset + 0x4 # float
    ExtHitShieldstunMultiplierOffset = ExtHitSDIMultiplierOffset + 0x4 # float
    ExtHitHitstunModifierOffset = ExtHitShieldstunMultiplierOffset + 0x4 # float

    ExtHitFlags1Offset = ExtHitHitstunModifierOffset + 0x4 # char
    ExtHitFlags1IsWindBoxMask = 0x1

    ExtHitFlippyTypeOffset = ExtHitFlags1Offset + 0x4 # int
# Size of new hitbox data = last var offset + last var offset.size
const ExtHitSize = ExtHitFlippyTypeOffset + 0x4

# New variable pointer offsets for both ITEMS & FIGHTERS
const
    ExtHit0Offset = 0x0
    ExtHit1Offset = ExtHit0Offset + ExtHitSize
    ExtHit2Offset = ExtHit1Offset + ExtHitSize
    ExtHit3Offset = ExtHit2Offset + ExtHitSize

# New variable pointer offsets for FIGHTERS only
const
    SDIMultiplierOffset = ExtHit3Offset + ExtHitSize # float
    HitstunModifierOffset = SDIMultiplierOffset + 0x4 # float
    ShieldstunMultiplierOffset = HitstunModifierOffset + 0x4 # float

# New variable pointer offsets for ITEMS only
const
    ExtItHitlagMultiplierOffset = ExtHit3Offset + ExtHitSize # float

const 
    ExtFighterDataSize = (ShieldstunMultiplierOffset + 0x4)
    ExtItemDataSize = (ExtItHitlagMultiplierOffset + 0x4) 

const
    NewFighterDataSize = FighterDataOrigSize + ExtFighterDataSize
    NewItemDataSize = ItemDataOrigSize + ExtItemDataSize

const
    CustomFunctionReadEvent = "0x801510e0"
    CustomFunctionInitDefaultEventVars = "0x801510e4"

const 
    FlippyTypeNone = 0
    FlippyTypeOpposite = 1
    FlippyTypeForward = 2

proc calcOffsetFighterExtData(varOff: int): int = ExtFighterDataOffset + varOff
proc calcOffsetItemExtData(varOff: int): int = ExtItemDataOffset + varOff

defineCodes:
    createCode "Hitbox Extension":
        description ""
        authors "Ronnie/sushie"

        patchInsertAsm "801510d8":
            # custom function that finds the appropriate ExtHit offset for a given hitbox struct ptr
            cmpwi r4, 343
            %`beq-`(OriginalExit)
            # uses
            # r3, r4, r5, r6, r7, r8
            # inputs
            # r3 = ft/itdata
            # r4 = ft/ithit
            # r5 = ft/ithit start offset relative to ft/itdata
            # r6 = ft/ithit struct size
            # r7 = ExtItem/Fighter offset
            # outputs
            # r3 = ptr to ExtHit
            add r8, r3, r5
            # r5 is now free to use
            li r5, 0
            b Comparison
            Loop:
                addi r5, r5, 1
                cmpwi r5, 3
                %`bgt-`(NotFound)
                add r8, r8, r6
                Comparison:
                    cmplw r8, r4
                    %`bne+`(Loop)
            Found:
                mulli r5, r5, {ExtHitSize}
                add r5, r5, r7
                add r5, r3, r5
                mr r3, r5
                blr
            NotFound:
                li r3, 0
                blr

            OriginalExit:
                lfs f1, -0x5B40(rtoc)

#[         # Enable bit 0x40 - Blockability (Can Shield) flag of ItHit to be usable for Fighter Hitboxes
        patchInsertAsm "80078fe8":
            # can hit fighters through shield if 0x40 is set to 0
            lbz r0, 0x42(r23)
            %`rlwinm.`(r0, r0, 26, 31, 31)
            bne OriginalExit
            SkipShield:
                %branch("0x800790B4")
            OriginalExit:
                %`rlwinm.`(r0, r3, 28, 31, 31) # original code line
 ]#
        # Hitlag multiplier mechanics patch for fighters
        patchInsertAsm "8007db1c":
            # fix for fighters only...
            # TODO double check... should check if fighter is in hitlag... still has 1 frame of hitlag if fighter isn't in hitlag??? maybe not
            # fixes a freeze glitch that occurs when a fighter is in hitlag but then gets hit with a move with 0 hitlag
            # f1 = calculated hitlag frames
            # if our calculated hitlag is less than 1, set it to 1
            lfs f0, -0x7790(rtoc) # 1.0
            fcmpo cr0, f1, f0
            %`bge+`(Exit)
            fmr f1, f0
            Exit:
                addi sp, sp, 64 # orig code line

#[         # Custom Function for Set Weight to 100 for Knockback Calculation (ExtHit Flag)
        patchInsertAsm "801510d4":

            cmpwi r4, 343
            %`beq-`(OriginalExit)

            mflr r0

            # r3 = attacker data
            # r4 = defender data
            # r5 = hit struct

            # returns f1 = weight
            mr r4, r5
            li r5, 2324
            li r6, 312
            li r7, {ExtFighterDataOffset}
            %branchLink("0x801510d8")

            mtlr r0

            cmpwi r3, 0
            beq Epilog

            # r3 contains ExtHit offset
            lbz r4, {ExtHitFlags1Offset}(r3)
            %`rlwinm.`(r4, r4, 0, 24, 24)
            beq UseDefaultWeight

            SetWeight:
                lwz r3, -0x514C(r13)
                lfs f1, 0x10C(r3) # uses same weight value from throws (100)
                b Epilog

            UseDefaultWeight:
                li r3, 0

            Epilog:
                blr

            OriginalExit:
                lwz r31, 0x002C(r3)

        # Set Weight to 100 for Knockback Calculation (ExtHit Flag)
        patchInsertAsm "8007a14c":
            # r25 = defender data
            # r17 = hit struct?
            # r15 = attacker data
            %backup

            mr r25, r27

            mr r31, r3
            mr r30, r4
            mr r29, r5
            mr r28, r6
            mr r27, r7
            mr r26, r8
            stfd f1, {BackupFreeSpaceOffset}(sp) 

            mr r3, r15
            mr r4, r25
            mr r5, r17
            %branchLink("0x801510d4")
            cmpwi r3, 0
            beq UseDefaultWeight

            fmr f4, f1 # original code line uses f4 as the weight val
            b Exit

            UseDefaultWeight:
                lfs f4, 0x88(r27) # loads defender's weight

            Exit:
                lfd f1, {BackupFreeSpaceOffset}(sp)
                %restore



        # Set Weight to 100 for Knockback Calculation (ExtHit Flag)
        # Called when defender is attacked by an item
        patchInsertAsm "8007a270":
            # r25 = def data
            lwz r4, 0xC(r19) # get it/ft of last hit
            %branchLink("0x801510d4", r3)
            lfs f22, 0x88(r27) # original code line
 ]#
        # SDI multiplier mechanics patch
        patchInsertAsm "8008e558":
            # SDI distance is increased or decreased based on multiplier
            # r3 = fighter data
            # f4 = 6.0 multiplier
            lfs f0, {calcOffsetFighterExtData(SDIMultiplierOffset)}(r3)
            fmuls f4, f4, f0 # 6.0 * our custom sdi multiplier
            li r0, 254 # original code line

        # Hitstun mechanics patch
        patchInsertAsm "8008dd70":
            # Adds or removes frames of hitstun
            # 8008dd68: loads global hitstun multiplier of 0.4 from plco
            # f30 = calculated hitstun after multipling by 0.4
            # r29 = fighter data
            # f0 = free
            lfs f0, {calcOffsetFighterExtData(HitstunModifierOffset)}(r29) # load modifier
            fadds f30, f30, f0 # hitstun + modifier
            fctiwz f0, f30 # original code line

        # Shieldstun multiplier mechanics patch
        patchInsertAsm "8009304c":
            # TODO yoshi's shield
            # Shieldstun for defender is increased or decreased based on multiplier
            # f4 = 1.5
            # f0 is free here
            # r31 = fighter data
            lfs f0, {calcOffsetFighterExtData(ShieldstunMultiplierOffset)}(r31) # load modifier
            fmuls f4, f4, f0 # 1.5 * our multiplier
            fsubs f2, f2, f3 # orig code line

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
            %backup
            # backup regs
            # r31 = source data
            # r30 = defender data
            # r29 = r5 ft/it hit
            # r27 = r3 source gobj
            # r26 = r4 defender gobj

            lwz r31, 0x2C(r3)
            lwz r30, 0x2C(r4)
            mr r29, r5
            mr r27, r3
            mr r26, r4

            # calculate ExtHit offset for given ft/it hit ptr
            mr r3, r27 # src gobj
            bl IsItemOrFighter
            mr r25, r3 # backup source type
            cmpwi r3, 1
            beq SetupFighterVars
            cmpwi r3, 2
            bne Epilog

            SetupItemVars:
                li r5, 1492
                li r6, 316
                li r7, {ExtItemDataOffset}
            b CalculateExtHitOffset

            SetupFighterVars:
                li r5, 2324
                li r6, 312
                li r7, {ExtFighterDataOffset}

            CalculateExtHitOffset:
                mr r3, r31
                mr r4, r29
                %branchLink("0x801510d8")
            # r3 now has offset
            cmpwi r3, 0
            beq Epilog

            mr r28, r3 # ExtHit off

            # r25 = source type
            # r24 = defender type
            # r28 = ExtHit offset

            StoreHitlag:
                lfs f0, {ExtHitHitlagOffset}(r28) # load hitlag mutliplier
                # calculate hitlag multiplier offsets depending if it's a item or fighter
                # for src
                mr r3, r25
                bl CalculateHitlagMultiOffset
                add r4, r31, r3

                # for def
                mr r3, r26
                bl IsItemOrFighter
                mr r24, r3 # backup def type
                bl CalculateHitlagMultiOffset
                add r5, r30, r3
               
                Hitlag:
                    # check if hit was electric
                    lwz r0, 0x30(r29) # dmg hit attribute
                    cmplwi r0, 2 # electric
                    %`bne+`(NotElectric)
                    # Electric
                    lwz r3, -0x514C(r13) # PlCo values
                    lfs f1, 0x1A4(r3) # 1.5 electric hitlag multiplier
                    fmuls f1, f1, f0 # 1.5 * multiplier
                    # store extra hitlag for DEFENDER ONLY in Melee
                    # TODO idk if i should check if src & defender data is valid before setting...
                    stfs f1, 0(r5) # store extra hitlag for defender
                    b UpdateHitlagForAttacker

                    NotElectric:
                            stfs f0, 0(r5) # store hitlag multi for defender

                            UpdateHitlagForAttacker:
                                stfs f0, 0(r4) # store hitlag multi for source
                                
            # now we store other variables for defenders who are fighters ONLY
            cmpwi r24, 1 # fighter
            bne Epilog # not fighter, skip this section      

            StoreHitstunModifier:
                lfs f0, {ExtHitHitstunModifierOffset}(r28)
                stfs f0, {calcOffsetFighterExtData(HitstunModifierOffset)}(r30)
                
            StoreSDIMultiplier:
                lfs f0, {ExtHitSDIMultiplierOffset}(r28)
                stfs f0, {calcOffsetFighterExtData(SDIMultiplierOffset)}(r30)
            
            CalculateFlippyDirection:
                # TODO flippy for items such as goombas??
                lwz r0, {ExtHitFlippyTypeOffset}(r28)
                cmpwi r0, {FlippyTypeNone}
                beq Epilog
                lfs f0, 0x2C(r31) # facing direction of attacker
                cmpwi r0, {FlippyTypeForward}
                bne StoreCalculatedDirection
                FlippyForward:
                    fneg f0, f0
                StoreCalculatedDirection:
                    stfs f0, 0x1844(r30)

            Epilog:
                %restore
                blr

            CalculateHitlagMultiOffset:
                cmpwi r3, 1
                beq Return1960
                cmpwi r3, 2
                bne Exit
                li r3, {calcOffsetItemExtData(ExtItHitlagMultiplierOffset)}
                b Exit
                Return1960:
                    li r3, 0x1960
                Exit:
                    blr

            IsItemOrFighter:
                # input = gobj in r3
                # returns 0 = ?, 1 = fighter, 2 = item, in r3
                lhz r0, 0(r3)
                cmpwi r0,0x4
                li r3, 1
                beq Result
                li r3, 2
                cmpwi r0,0x6
                beq Result
                li r3, 0
                Result:
                    blr

            OriginalExit:
                lwz r5, 0x010C(r31)

        # Hitbox_MeleeLogicOnShield - Set Hit Vars
        patchInsertAsm "80076dec":
            # r31 = defender data
            # r30 = hit struct
            # r29 = src data
            # free regs to use: r0, f1, f0
            mr r0, r3 # backup r3

            mr r3, r29 # src data
            mr r4, r30 # hit struct
            li r5, 2324
            li r6, 312
            li r7, {ExtFighterDataOffset}
            %branchLink("0x801510d8")
            cmpwi r3, 0
            beq Exit

            # r3 = exthit
            lfs f0, {ExtHitShieldstunMultiplierOffset}(r3)
            stfs f0, {calcOffsetFighterExtData(ShieldstunMultiplierOffset)}(r31)

            Exit:
                # restore r3
                mr r3, r0
                lwz r0, 0x30(r30) # original code line

        # Hitbox_ProjectileLogicOnShield - Set Hit Vars
        patchInsertAsm "80077918":
            # r29 = defender data
            # r28 = hit struct
            # r27 = src data
            # free regs to use f1, f0
            mr r3, r27 # src data
            mr r4, r28 # hit struct
            li r5, 1492
            li r6, 316
            li r7, {ExtItemDataOffset}
            %branchLink("0x801510d8")
            cmpwi r3, 0
            beq Exit

            # r3 = exthit
            lfs f0, {ExtHitShieldstunMultiplierOffset}(r3)
            stfs f0, {calcOffsetFighterExtData(ShieldstunMultiplierOffset)}(r29)

            Exit:
                # restore r6
                mr r6, r30
                stw r0, 0x19B0(r29) # original code line


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
            %branchLink("0x801510dc")
            Exit:
                lwz r0, 0xCA0(r31) # original code line

        # CalculateKnockback patch for setting hit variables that affect the defender and attacker
        patchInsertAsm "8007aaf4":
            # r12 = source ftdata
            # r25 = defender ftdata
            # r31 = ptr ft hit
            # r30 = gobj of defender
            # r4 = gobj of src
            lwz r3, 0x8(r19)
            mr r4, r30
            lwz r5, 0xC(r19) # ptr fthit of source
            %branchLink("0x801510dc") # TODO const...
            %branch("0x8007ab0c")

        # Hitlag Function For Other Entities
        patchInsertAsm "8026b454":
            # patch hitlag function used by other entities
            # r31 = itdata
            # f0 = floored hitlag frames
            lfs f1, {calcOffsetItemExtData(ExtItHitlagMultiplierOffset)}(r31)
            fmuls f0, f0, f1 # calculated hitlag frames * multiplier

            # check if calculated hitlag is 0, then set it to a minimum of 1
            lfs f1, -0x7790(rtoc) # 1.0
            fcmpo cr0, f0, f1
            %`bge+`(Exit)
            fmr f0, f1 # set f0 to 1.0

            Exit:
                fctiwz f0, f0

        # Reset Custom Variables for Items
        patchInsertAsm "80269cdc":
            # r5 = itdata

            # reset custom vars to 1.0
            lfs f0, -0x7790(rtoc) # 1.0            
            stfs f0, {calcOffsetItemExtData(ExtItHitlagMultiplierOffset)}(r5)

            # reset custom vars to 0.0
            lfs f0, -0x33A8(rtoc) # 0.0, original code line


        # Init Default Values for ExtHit - Projectiles
        patchInsertAsm "802790f0":
            # r4 = hitbox id
            # r30 = item data??

            mulli r3, r4, {ExtHitSize}
            addi r3, r3, {ExtItemDataOffset}
            add r3, r30, r3
            # save r4 to r28
            mr r28, r4
            %branchLink(CustomFunctionInitDefaultEventVars)
            # restore r4
            mr r4, r28
            Exit:
                mulli r3, r4, 316 # orig code line

        # Init Default Values for ExtHit - Melee
        patchInsertAsm "8007127c":
            # r0 = hitbox ID
            # r31 = fighter data

            mulli r3, r0, {ExtHitSize}
            addi r3, r3, {ExtFighterDataOffset}
            add r3, r31, r3

            # backup r4 to r5
            mr r5, r4
            %branchLink(CustomFunctionInitDefaultEventVars)

            # restore r4
            mr r4, r5
            
            Exit:
                mulli r3, r0, 312 # orig code line

        # Reset Custom ExtFighterData vars that are involved at the end of Hitlag for Fighters
        patchInsertAsm "8006d1d8":
            # reset vars that need to be 1
            # r31 = fighter data
            lfs f0, -0x7790(rtoc) # 1
            stfs f0, {calcOffsetFighterExtData(SDIMultiplierOffset)}(r31)
            Exit:
                lwz r0, 0x24(sp)

        # Reset Custom ExtFighterData vars that are involved with PlayerThink_Shield/Damage
        patchInsertAsm "8006d8fc":
            # reset custom ExtData vars for fighter
            # f1 = 0.0
            # r3 = 0
            # r30 = fighter data
            # reset vars to 0
            stfs f1, {calcOffsetFighterExtData(HitstunModifierOffset)}(r30)
            stfs f1, 0x1838(r30) # original code line
            # reset vars to 1.0
            lfs f0, -0x7790(rtoc) # 1.0
            stfs f0, {calcOffsetFighterExtData(ShieldstunMultiplierOffset)}(r30)

        # Custom Non-Standalone Function For Initing Default Values in ExtHit
        patchInsertAsm "801510e4":
            # TODO samus create hitbox?
            cmpwi r4, 343
            %`beq-`(OriginalExit)

            # reset vars that need to be 1
            lfs f0, -0x7790(rtoc) # 1
            stfs f0, {ExtHitHitlagOffset}(r3)
            stfs f0, {ExtHitSDIMultiplierOffset}(r3)
            stfs f0, {ExtHitShieldstunMultiplierOffset}(r3)

            # reset vars that need to be 0
            lfs f0, -0x778C(rtoc) # 0.0
            stfs f0, {ExtHitHitstunModifierOffset}(r3)
            li r4, 0
            stw r4, {ExtHitFlags1Offset}(r3)
            stw r4, {ExtHitFlippyTypeOffset}(r3)
            blr

            OriginalExit:
                lfs f2, -0x5B3C(rtoc) # orig code line

        # Custom Non-Standalone Function For Reading Subaction Event Data
        patchInsertAsm "801510e0":
            cmpwi r4, 343
            %`beq-`(OriginalExit)

            # r5 = ExtItem/FighterDataOffset
            # r30 = item/fighter data
            lwz r3, 0x8(r29) # load current subaction ptr
            lbz r4, 0x3(r3) # load hitbox id
            mulli r4, r4, {ExtHitSize}
            add r4, r4, r5
            add r4, r30, r4

            # r4 = the ptr to which ExtHit we are dealing with
            lwz r6, -0x514C(r13) # static vars??
            lfs f1, 0xF4(r6) # load 0.01 into f1

            # read hitlag & sdi multipliers
            psq_l f0, 0x4(r3), 0, 5 # load both hitlag & sdi multipliers into f0 (ps0 = hitlag multi, ps1 = sdi multi)
            ps_mul f0, f1, f0 # multiply both hitlag & sdi multipliers by f1 = 0.01
            psq_st f0, {ExtHitHitlagOffset}(r4), 0, 7 # store calculated hitlag & sdi multipliers next to each other

            # read shieldstun multiplier & hitstun modifier
#            lfd f1, 0xF4(r6) # load 0.01 into f1(ps0)
            psq_l f1, 0xF4(r6), 1, 7 # load 0.01 in f1(ps0), 1.0 in f1(ps1)
            psq_l f0, 0x8(r3), 0, 5 # load shieldstun multi in f0(ps0), hitstun mod in f0(ps1)
            ps_mul f0, f1, f0 # shieldstun multi * 0.01, hitstun mod * 1.00
            psq_st f0, {ExtHitShieldstunMultiplierOffset}(r4), 0, 7 # store results next to each other

            # read isWindbox & Flippy bits
            lbz r6, 0xC(r3)
            %`rlwinm.`(r0, r6, 0, 24, 24)
            li r0, 1
            bne IsWindBox

            b CheckFlippy

            IsWindBox:
#                # blockability related
#                mulli r7, r4, 312
#                addi r7, r7, 2324
#                add r7, r30, r7
                
#                lbz r5, 0x42(r7)
#                rlwimi r5, r0, 0, 0x40
#                stb r5, 0x42(r7)

                lbz r5, {ExtHitFlags1Offset}(r4)
                # r0 = 1 here
                rlwimi r5, r0, 0, {ExtHitFlags1IsWindBoxMask} # is windbox flag
                stb r0, {ExtHitFlags1Offset}(r4)

            CheckFlippy:
                %`rlwinm.`(r5, r6, 0, 25, 25) # opposite facing direction flippy
                # r0 = 1
                bne StoreFlippyType
                %`rlwinm.`(r5, r6, 0, 26, 26) # towards facing direction flippy
                li r0, 2
                bne StoreFlippyType
                li r0, 0
                StoreFlippyType:
                    stw r0, {ExtHitFlippyTypeOffset}(r4)

            # advance script
            addi r3, r3, 16 # TODO create a function to calculate this
            stw r3, 0x8(r29) # store current pointing ptr
            blr

            OriginalExit:
                fmr f3, f1

        # Custom Fighter Subaction Event
        patchInsertAsm "80073318":
            # use 0xF1 as code, make sure r28 == 0x3c
            # r27 = item/fighter gobj
            # r29 = script struct ptr
            # r30 = item/fighter data
            cmpwi r28, 0x3C
            %`bne+`(OriginalExit)
            li r5, {ExtFighterDataOffset}
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
            li r5, {ExtItemDataOffset}
            %branchLink(CustomFunctionReadEvent)
            %branch("0x80279ad0")
            OriginalExit:
                lwz r12, 0(r3)

        #[EXTEND ITEMBLOCK]#

        # Adjust the size
        patchWrite32Bits "80266fd8":
            li r4, {NewItemDataSize}

        # Initialize Extended Item Data
        patchInsertAsm "80268754":
            addi r29, r3, 0 # backup r3

            li r4, {NewItemDataSize} # was 4044
            %branchLink("0x8000c160")

            Exit:
                mr r3, r29 # restore r3
                %`mr.`(r6, r3)

        #[EXTEND PLAYERBLOCK]#

        # Fix 20XX Crash when Allocating New PlayerBlock Size
        # TODO REMOVE IF NOT USING 20XX
        patchWrite32Bits "8013651c":
            blr # this breaks 'Marth and Roy Sword Swing File Colors'!!!

        # Adjust the size
        patchWrite32Bits "800679bc":
            li r4, {NewFighterDataSize}

        # Initialize Extended Playerblock Values
        patchInsertAsm "80068eec":
            # credits to https://github.com/UnclePunch/Training-Mode/blob/master/ASM/m-ex/Custom%20Playerdata%20Variables/Initialize%20Extended%20Playerblock%20Values.asm

            # TODO remove NonVanilla20XX if not using 20XX!!!
            NonVanilla20XX:
                li r4, 0
                stw r4, 0x20(r31)
                stw r4, 0x24(r31)
                stb r4, 0x0D(r3)
                sth r4, 0x0E(r3)
                stb r4, 0x21FD(r3)
                sth r4, 0x21FE(r3)

            # Backup Data Pointer After Creation
            addi r30, r3, 0

            # Get Player Data Length
            %load("0x80458fd0", r4)
            lwz r4,0x20(r4)
            # Zero Entire Data Block
            %branchLink("0x8000c160")

            Exit:
                mr r3, r30
                lis r4, 0x8046

        # Initialize Extended Playerblock Values (Result screen)
        patchInsertAsm "800BE830":
            # Backup Data Pointer After Creation
            addi r30, r3, 0

            # Get Player Data Length
            %load("0x80458fd0", r4)
            lwz r4,0x20(r4)
            # Zero Entire Data Block
            %branchLink("0x8000c160")

            Exit:
                mr r3, r30
                lis r4, 0x8046

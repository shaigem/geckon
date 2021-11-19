import geckon

# TODO add m-ex support
# TODO item support

const
    FighterDataOrigSize = 0x23EC
    ItemDataOrigSize = 0xFCC
    ExtFighterDataOffset = FighterDataOrigSize
    ExtItemDataOffset = ItemDataOrigSize

# Variable offsets in our new ExtHit struct
const
    ExtHitHitlagOffset = 0x0 # float
    ExtHitSDIMultiplierOffset = ExtHitHitlagOffset + 0x4 # float
    ExtHitHitstunModifierOffset = ExtHitSDIMultiplierOffset + 0x4 # float

    ExtHitFlags1Offset = ExtHitHitstunModifierOffset + 0x4 # char
    ExtHitFlags1IsWindBoxMask = 0x1

    ExtHitFlippyTypeOffset = ExtHitFlags1Offset + 0x4 # int
# Size of new hitbox data = last var offset + last var offset.size
const ExtHitSize = ExtHitFlippyTypeOffset + 0x4

echo ExtHitSize

# New variable pointer offsets
const
    ExtHit0Offset = 0x0
    ExtHit1Offset = ExtHit0Offset + ExtHitSize
    ExtHit2Offset = ExtHit1Offset + ExtHitSize
    ExtHit3Offset = ExtHit2Offset + ExtHitSize
    SDIMultiplierOffset = ExtHit3Offset + ExtHitSize # float
    HitstunModifierOffset = SDIMultiplierOffset + 0x4 # float
const ExtDataSize = (HitstunModifierOffset + 0x4)

const
    NewFighterDataSize = FighterDataOrigSize + ExtDataSize
    NewItemDataSize = ItemDataOrigSize + ExtDataSize

const
    CustomFunctionReadEvent = "0x801510e0"
    CustomFunctionInitDefaultEventVars = "0x801510e4"

proc calcOffsetExtHit(hitboxIdReg, fighterDataReg: Register; outputReg: Register = hitboxIdReg; extDataOffset: int64 = ExtFighterDataOffset): string =
    # hitbox id * ExtHit struct size = offset ptr
    # offset ptr * first of ExtHit[4] ptr offset = offset ptr relative to fighter data
    # fighter data ptr start + offset ptr relative to fighter data = ptr offset of ExtHit
    if outputReg == fighterDataReg:
        raise newException(ValueError, "output register should not be the same as the fighter data reg!")
    &"""mulli {outputReg}, {hitboxIdReg}, {ExtHitSize}
addi {outputReg}, {outputReg}, {extDataOffset}
add {outputReg}, {fighterDataReg}, {outputReg}"""

defineCodes:
    createCode "Hitbox Extension":
        description ""
        authors "Ronnie/sushie"

        patchInsertAsm "801510d8":
            # custom function that finds the appropriate ExtHit offset for a given hitbox struct ptr
            cmpwi r4, 343
            %`beq-`(OriginalExit)
            # uses
            # r0, r3, r4, r5, r6, r7, r8
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

        # Hitlag
        patchInsertAsm "8007db1c":
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

        patchInsertAsm "8007aaf4":
            # set the hitlag multiplier for the attacker & defender based on hitbox id
            # r12 = source ftdata
            # r25 = defender ftdata
            # r31 = ptr ft hit
            lwz r4, 0x8(r19)
            lhz r3, 0(r4)
            cmpwi r3,0x4
            beq Fighter
            cmpwi r3,0x6
            bne OriginalExit

            # TODO rewrite for cleaner

            Item:
                #mr r3, r12
                lwz r3, 0x2C(r4)
                lwz r4, 0xC(r19) # ptr fthit of source
                li r5, 1492
                li r6, 316
                li r7, {ExtItemDataOffset}
                %branchLink("0x801510d8", r8)
            
            b CheckValidExtHitStruct

            Fighter:
                mr r3, r12
                lwz r4, 0xC(r19) # ptr fthit of source
                li r5, 2324
                li r6, 312
                li r7, {ExtFighterDataOffset}
                %branchLink("0x801510d8", r8)
            
            CheckValidExtHitStruct:
                cmpwi r3, 0
                beq OriginalExit

            # r3 now contains ptr to ExtHit struct start

            lwz r0, 0x1C(r31) # dmg hit attribute
            cmplwi r0, 2 # hit electric attribute
            lfs f31, {ExtHitHitlagOffset}(r3) # load hitlag mutliplier into f31
            %`bne-`(NotElectric)

            # attribute was electric
            lwz r4, -0x514C(r13)
            lfs f0, 0x1A4(r4) # 1.5 electric hitlag multiplier
            fmuls f0, f31, f0 # 1.5 * extra hitlag
            stfs f0, 0x1960(r25) # store extra hitlag for defender
            b StoreForAttacker

            NotElectric:
                stfs f31, 0x1960(r25) # store hitlag for defender
                StoreForAttacker: # TODO STAGE ITEMS CAUSE THIS PART TO CRASH
                    stfs f31, 0x1960(r12) # store hitlag for attacker

            %branch("0x8007ab0c")

            OriginalExit:
                lwz r0, 0x1C(r31)

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
#[            
            # Init Default Values for ExtHit - Projectiles
        patchInsertAsm "802790f0":
            # r4 = hitbox id
            # r27 = item data

            # call the custom function
            mr r3, r4 # hitbox id
            mr r4, r27 # item data
            li r5, {ExtItemDataOffset}
            %branchLink(CustomFunctionInitDefaultEventVars)

            # restore r4
            mr r4, r3
            # r5 was restored already

            Exit:
                mulli r3, r4, 316 # orig code line

        # Init Default Values for ExtHit - Melee
        patchInsertAsm "8007127c":
            # r0 = hitbox ID
            # r31 = fighter data
            mr r3, r0
            mr r4, r31
            li r5, {ExtFighterDataOffset}
            %branchLink(CustomFunctionInitDefaultEventVars)

            # restore r0 & r31
            mr r0, r3
            mr r31, r4
            # r5 was restored already
            
            Exit:
                mulli r3, r0, 312 # orig code line

            # Init Default Values for ExtHit - Projectiles
        patchInsertAsm "802790f0":
            # r4 = hitbox id
            # r27 = item data

            # backup r4 ONLY to r28
            mr r28, r4

            # call the custom function
            mr r3, r4 # hitbox id
            mr r4, r27 # item data
            %branchLink(CustomFunctionInitDefaultEventVars)

            # restore r4
            mr r4, r28
            
            Exit:
                mulli r3, r4, 316 # orig code line

        # Init Default Values for ExtHit - Melee
        patchInsertAsm "8007127c":
            # r0 = hitbox ID
            # r31 = fighter data

            # backup r0 & r4
            mr r30, r0
            mr r5, r4

            # call the custom function
            mr r3, r0 # hitbox id
            mr r4, r31 # item data
            %branchLink(CustomFunctionInitDefaultEventVars)

            # restore r0 & r4
            mr r0, r30
            mr r4, r5
            Exit:
                mulli r3, r0, 312 # orig code line
     # TODO add to projectiles func & samus create hitbox?
            # must init default values of ExtHit for every hitbox even if it doesn't use the custom subaction event
            # r31 = fighter data
            # r0 = hitbox ID
            # r30 = free
            %calcOffsetExtHit(r0, r31, outputReg = r30)
            # reset vars that need to be 1
            lfs f0, -0x7790(rtoc) # 1
            stfs f0, {ExtHitHitlagOffset}(r30)
            stfs f0, {ExtHitSDIMultiplierOffset}(r30)

            # reset vars that need to be 0
            lfs f0, -0x778C(rtoc) # 0.0
            stfs f0, {ExtHitHitstunModifierOffset}(r30)
            li r3, 0
            stw r3, {ExtHitFlags1Offset}(r30)
            stw r3, {ExtHitFlippyTypeOffset}(r30)

            Exit:
                mulli r3, r0, 312 # orig code line 
                
                        # Custom Non-Standalone Function For Initing Default Values in ExtHit
        patchInsertAsm "801510e4":
            cmpwi r4, 343
            %`beq-`(OriginalExit)

            # inputs
            # r3 = hitbox ID
            # r4 = fighter data
            # r5 = exthit offset to use
            %backup
            # backed up regs
            mr r31, r4
            mr r30, r3
            mr r29, r5

            #%calcOffsetExtHit(r30, r31, outputReg = r3)
            mulli r3, r30, {ExtHitSize}
            add r3, r3, r5
            add r3, r31, r3

            # reset vars that need to be 1
            lfs f0, -0x7790(rtoc) # 1
            stfs f0, {ExtHitHitlagOffset}(r3)
            stfs f0, {ExtHitSDIMultiplierOffset}(r3)

            # reset vars that need to be 0
            lfs f0, -0x778C(rtoc) # 0.0
            stfs f0, {ExtHitHitstunModifierOffset}(r3)
            li r4, 0
            stw r4, {ExtHitFlags1Offset}(r3)
            stw r4, {ExtHitFlippyTypeOffset}(r3)

            # restore messed up registers
            mr r4, r31
            mr r3, r30
            mr r5, r29

            %restore
            blr
            OriginalExit:
                lfs f2, -0x5B3C(rtoc) # orig code line
                ]#

        # Custom Non-Standalone Function For Initing Default Values in ExtHit
        patchInsertAsm "801510e4":
            cmpwi r4, 343
            %`beq-`(OriginalExit)

            # reset vars that need to be 1
            lfs f0, -0x7790(rtoc) # 1
            stfs f0, {ExtHitHitlagOffset}(r3)
            stfs f0, {ExtHitSDIMultiplierOffset}(r3)

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

            # r5 = ExtFighterDataOffset
            # r30 = item/fighter data
            lwz r3, 0x8(r29) # load current subaction ptr
            lbz r4, 0x3(r3) # load hitbox id
            mulli r4, r4, {ExtHitSize}
            add r4, r4, r5
            add r4, r30, r4
#            %calcOffsetExtHit(r4, r30, extDataOffset = ExtFighterDataOffset)

            # r4 = the ptr to which ExtHit we are dealing with
            lwz r6, -0x514C(r13) # static vars??
            lfs f1, 0xF4(r6) # load 0.01 into f0

            # read hitlag & sdi multipliers
            psq_l f0, 0x4(r3), 0, 5 # load both hitlag & sdi multipliers into f0 (ps0 = hitlag multi, ps1 = sdi multi)
            ps_mul f0, f1, f0 # multiply both hitlag & sdi multipliers by f1 = 0.01
            psq_st f0, {ExtHitHitlagOffset}(r4), 0, 7 # store calculated hitlag & sdi multipliers next to each other

            # read hitstun modifier
            psq_l f0, 0x8(r3), 1, 5 # load as float into ps0
            stfs f0, {ExtHitHitstunModifierOffset}(r4) # store into ftdata

            # read isWindbox & Flippy bits
            lbz r6, 0xA(r3)
            %`rlwinm.`(r0, r6, 0, 24, 24)
            li r0, 1
            bne IsWindBox

            b CheckFlippy

            IsWindBox:
                lbz r5, {ExtHitFlags1Offset}(r4)
                # r0 = 1 here
                rlwimi r5, r0, 0, {ExtHitFlags1IsWindBoxMask} # is windbox flag
                stb r0, {ExtHitFlags1Offset}(r4)

            CheckFlippy:
                %`rlwinm.`(r6, r6, 0, 25, 25) # opposite facing direction flippy
                # r0 = 1
                bne StoreFlippyType
                %`rlwinm.`(r6, r6, 0, 26, 26) # towards facing direction flippy
                li r0, 2
                bne StoreFlippyType
                li r0, 0
                StoreFlippyType:
                    stw r0, {ExtHitFlippyTypeOffset}(r4)

            # advance script
            addi r3, r3, 12 # TODO create a function to calculate this
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

            li r4, 4044
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

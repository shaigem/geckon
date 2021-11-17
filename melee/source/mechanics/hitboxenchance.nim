import geckon


const 
    FighterDataOrigSize = 0x23EC # TODO should just get the offset dynamically, also WHY TF does it crash with marth on 20xx
    ExtCustomHitboxDataSize = 0x10
    ExtFighterDataSize = ((ExtCustomHitboxDataSize * 4) + 0x8)
const
    FighterDataStart = 0x0
    ExtFighterDataStart = FighterDataStart + FighterDataOrigSize
    FighterDataTotalSize = FighterDataOrigSize + ExtFighterDataSize

# Custom Fighter Data Vars
const 
    ExtSDIMultiplier = ExtFighterDataStart + ((ExtCustomHitboxDataSize * 4)) + 0x0 # float
    ExtHitstunModifier = ExtFighterDataStart + ((ExtCustomHitboxDataSize * 4)) + 0x4 # float


echo ExtFighterDataSize

#[ 

struct extrahitboxdef 
- Hitlag: float
- SDI: float
- Hitstun: float
- Extra hitbits: ???
    - Angle flipping/reversible knockback toggle

Custom Vars:

    SDI Multiplier: float
    Hitstun Modifier: float

 ]#


# TODO variables & subaction hitbox data should reset ... for example, hitstun modifier is still there when someone uses a throw
# TODO there was a freeze glitch similar to ice climbers freeze glitch wtf
defineCodes:
    createCode "Fighter Data Hitbox Extension":
        description ""
        authors "Ronnie/sushie"
        # init/reset default custom fighter hitbox vars
        patchInsertAsm "8007127c":
            # r31 = fighter data
            # r0 = hitbox ID
            mulli r3, r0, {ExtCustomHitboxDataSize} # offset for hitbox
            addi r30, r3, {ExtFighterDataStart} # offset relative to fighter data
            add r30, r31, r30 # r30 now points to our custom hitbox struct
            lfs f0, -0x76F0(rtoc) # -1 TODO use just 1...
            fneg f0, f0
            stfs f0, 0(r30) # hitlag var
            stfs f0, 4(r30) # sdi var

            fsubs f0, f0, f0 # get 0 or use             lfs f0, -0x7700(rtoc) # 0
            stfs f0, 8(r30) # hitstun var

            li r3, 0
            stb r3, 0xD(r30) # reset flipper flag to 0

            mulli r3, r0, 312 # orig code line

        # sdi multiplier
        patchInsertAsm "8008e520":
            # TODO actually it's applied to the distance
            fadds f1, f1, f0 # (joyX * joyX) + (joyY * joyY)
            lfs f0, {ExtSDIMultiplier}(r3) # load custom sdi multiplier
            fmuls f1, f0, f1

            lfs f4, 0x4B0(r4) # orig code line
            %branch("0x8008e528")

            
            OriginalExit:
                lfs f4, 0x04B0(r4)

            Exit:
                %emptyBlock
            
            
        # hitstun mod
        patchInsertAsm "8008dd70":
            #hitstun modifier
            # 8008dd68: loads global hitstun multiplier of 0.4 from plco
            # f30 = calculated hitstun after multipling by 0.4
            # r29 = fighter data
            # f0 = free
            lfs f0, {ExtHitstunModifier}(r29) # load modifier
            fadds f30, f30, f0 # hitstun + modifier
            fctiwz f0, f30 # original code line

        patchInsertAsm "8007a77c":
            # reverse direction/angle flipper

            # r3 = source fighter data
            # r4 = ptr source fthit
            # r15 = source ptr data
            addi r18, r15, 2324
            cmplw r4, r18
            li r22, 0
            beq CalculateCustomOff

            addi r18, r18, 312
            cmplw r4, r18
            li r22, 1
            beq CalculateCustomOff
           
            addi r18, r18, 312
            cmplw r4, r18
            li r22, 2
            beq CalculateCustomOff      
            
            addi r18, r18, 312
            cmplw r4, r18
            li r22, 3
            beq CalculateCustomOff
            
            %branch("0x8007ab0c")

            CalculateCustomOff:
                mulli r22, r22, {ExtCustomHitboxDataSize}
                addi r22, r22, {ExtFighterDataStart}
                add r22, r15, r22

            lbz r18, 0xD(r22) # load flipper flags

            cmplwi r18, 0
            beq Exit
            lfs f0, 0x2C(r15) # source's direction
            cmplwi r18, 1 # same direction source is facing
            beq Exit
            cmplwi r18, 2 # reverse
            beq OppositeDirection

            OppositeDirection:
                fneg f0, f0

            Exit:
               fmr f24, f0


            

        # hitlag & sdi multiplier
        patchInsertAsm "8007aafc":
                    #[
            8007a770: lwz	r4, 0x000C (r17) # get FtHit of source
            lwz	r3, 0x0008 (r17) # source gobj
            r25 = victim's fighter data?
        ]#
        
            # r12 = source ftdata
            lwz r3, 0xC(r17) # ptr of fthit of source
            addi r4, r12, 2324
            cmplw r4, r3
            li r5, 0
            beq CalculateCustomOff

            addi r4, r4, 312
            cmplw r4, r3
            li r5, 1
            beq CalculateCustomOff
           
            addi r4, r4, 312
            cmplw r4, r3
            li r5, 2
            beq CalculateCustomOff            
            
            addi r4, r4, 312
            cmplw r4, r3
            li r5, 3
            beq CalculateCustomOff
            
            %branch("0x8007ab0c")

            CalculateCustomOff:
                mulli r5, r5, {ExtCustomHitboxDataSize}
                addi r5, r5, {ExtFighterDataStart}
                add r5, r12, r5 # r5 points to the correct spot


            lfs f31, 0(r5) # load hitlag multipleir
            cmplwi r0, 2
            %`bne-`(Exit)
            # electric

            lwz r3, -0x514C(r13)
            lfs f0, 0x01A4(r3) # 1.5 electric hitlag modifier
            fmuls f0, f0, f31 # 1.5 * extra hitlag
            stfs f0, 0x1960(r25) # store for victim
            b AfterElect

            Exit:
                stfs f31, 0x1960(r25) # store for victim
                
                AfterElect:
                    stfs f31, 0x1960(r12)

                    lfs f31, 4(r5) # load sdi multiplier
                    stfs f31, {ExtSDIMultiplier}(r25) # victim stored

                    lfs f31, 8(r5) # load hitstun mod
                    stfs f31, {ExtHitstunModifier}(r25) # victim stored
                    %branch("0x8007ab0c")


        # Custom subaction event
        patchInsertAsm "80073328":
            # TODO change injection addr and CODE type
            # r3 = fighter gobj
            # r4 = ?
            cmpwi r28, 0x3F
            %`bne-` OriginalExit
            lwz r6, 0x8(r4) # load current subaction ptr
            lbz r5, 0x3(r6) # load hitbox id
            lfs f1, 0x4(r6) # load hitlag multiplier

            lwz r7, 0x2C(r3) # load fighter data

            mulli r5, r5, {ExtCustomHitboxDataSize}
            addi r5, r5, {ExtFighterDataStart}
            add r5, r7, r5 # r5 points to the correct spot

            stfs f1, 0(r5) # store hitlag multiplier

            lfs f1, 0x8(r6) # load sdi multiplier
            stfs f1, 4(r5) # store sdi multiplier
           
            lfs f1, 0xC(r6) # load hitstun mod
            stfs f1, 8(r5) # store hitstun mod

            lbz r0, 0x10(r6) # load windbox bool
            # TODO windbox

            lbz r0, 0x11(r6) # load flipper flags
            stb r0, 0xD(r5) # store flipper flag

            # advance ptr
            addi r6, r6, 0x14 # change depending on # of args
            stw r6, 0x8(r4)

            b Exit

            OriginalExit:
                blrl
            
            Exit:
                %emptyBlock

        # EXTEND FIGHTER DATA ALLOCATION CODES

        # Adjust the size
        patchWrite32Bits "800679bc":
            li r4, {FighterDataTotalSize}

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



#[ import geckon


const 
    FighterDataOrigSize = 0x23EC # TODO should just get the offset dynamically
    ExtCustomHitboxDataSize = 0x8
    ExtFighterDataSize = (ExtCustomHitboxDataSize * 4) + 0x4
const
    FighterDataStart = 0x0
    ExtFighterDataStart = FighterDataStart + FighterDataOrigSize
    FighterDataTotalSize = FighterDataOrigSize + ExtFighterDataSize

# Custom Fighter Data Vars
const 
    ExtSDIMultiplier = ExtFighterDataStart + ((ExtCustomHitboxDataSize * 4)) + 0x0 # float

#[ 

struct extrahitboxdef 
- Hitlag: float
- SDI: float
- Hitstun: float
- Extra hitbits: ???
    - Angle flipping/reversible knockback toggle

Custom Vars:

    SDI Multiplier: float
 ]#


defineCodes:
    createCode "Fighter Data Hitbox Extension":
        description ""
        authors "Ronnie/sushie"
        # init default custom fighter hitbox vars
        patchInsertAsm "8007127c":
            # r31 = fighter data
            # r0 = hitbox ID
            mulli r3, r0, {ExtCustomHitboxDataSize} # offset for hitbox
            addi r30, r3, {ExtFighterDataStart} # offset relative to fighter data
            add r30, r31, r30 # r30 now points to our custom hitbox struct
            lfs f0, -0x76F0(rtoc) # -1 TODO use just 1...
            fneg f0, f0
            stfs f0, 0(r30) # hitlag var
            stfs f0, 4(r30) # sdi var
            mulli r3, r0, 312 # orig code line

        # sdi multiplier
        patchInsertAsm "8008e520":
            # TODO actually it's applied to the distance
            fadds f1, f1, f0 # (joyX * joyX) + (joyY * joyY)
            lfs f0, {ExtSDIMultiplier}(r3) # load custom sdi multiplier
            fmuls f1, f0, f1

            lfs f4, 0x4B0(r4) # orig code line
            %branch("0x8008e528")

            
            OriginalExit:
                lfs f4, 0x04B0(r4)

            Exit:
                %emptyBlock
            
            # TODO check if source != us???

        # hitlag & sdi multiplier
        patchInsertAsm "8007aafc":
                    #[
            8007a770: lwz	r4, 0x000C (r17) # get FtHit of source
            lwz	r3, 0x0008 (r17) # source gobj
            r25 = victim's fighter data?
        ]#
        
            # r12 = source ftdata
            lwz r3, 0xC(r17) # ptr of fthit of source
            addi r4, r12, 2324
            cmplw r4, r3
            li r5, 0
            beq CalculateCustomOff

            addi r4, r4, 312
            cmplw r4, r3
            li r5, 1
            beq CalculateCustomOff
           
            addi r4, r4, 312
            cmplw r4, r3
            li r5, 2
            beq CalculateCustomOff            
            
            addi r4, r4, 312
            cmplw r4, r3
            li r5, 3
            beq CalculateCustomOff
            
            %branch("0x8007ab0c")

            CalculateCustomOff:
                mulli r5, r5, {ExtCustomHitboxDataSize}
                addi r5, r5, {ExtFighterDataStart}
                add r5, r12, r5 # r5 points to the correct spot


            lfs f31, 0(r5)

            %`bne-`(Exit)
            # electric

            lwz r3, -0x514C(r13)
            lfs f0, 0x01A4(r3) # 1.5 electric hitlag modifier
            stfs f0, 0x1960(r25) # store for victim

            Exit:
                lfs f0, 0x1960(r25)
                fmuls f0, f0, f31 # 1.5 * extra hitlag
                stfs f0, 0x1960(r25) # store for victim

                lfs f0, 0x1960(r12) # hitlag mod of source
                fmuls f0, f0, f31
                stfs f0, 0x1960(r12)
                
                lfs f31, 4(r5) # load sdi multiplier
                stfs f31, {ExtSDIMultiplier}(r25) # victim stored
                %branch("0x8007ab0c")


        # Custom subaction event
        patchInsertAsm "80073328":
            # TODO change injection addr and CODE type
            # r3 = fighter gobj
            # r4 = ?
            cmpwi r28, 0x3F
            %`bne-` OriginalExit
            lwz r6, 0x8(r4) # load current subaction ptr
            lbz r5, 0x3(r6) # load hitbox id
            lfs f1, 0x4(r6) # load hitlag multiplier

            lwz r7, 0x2C(r3) # load fighter data

            mulli r5, r5, {ExtCustomHitboxDataSize}
            addi r5, r5, {ExtFighterDataStart}
            add r5, r7, r5 # r5 points to the correct spot

            stfs f1, 0(r5) # store hitlag multiplier

            lfs f1, 0x8(r6) # load sdi multiplier
            stfs f1, 4(r5) # store sdi multiplier
           
            # advance ptr
            addi r6, r6, 0xC # change depending on # of args
            stw r6, 0x8(r4)

            b Exit

            OriginalExit:
                blrl
            
            Exit:
                %emptyBlock

        # EXTEND FIGHTER DATA ALLOCATION CODES

        # Adjust the size
        patchWrite32Bits "800679bc":
            li r4, {FighterDataTotalSize}

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
 ]#
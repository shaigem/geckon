#[  
- code: 0xF5
  name: Set Special Hitbox Flags (Fighters)
  parameters:
  - name: Hitbox ID
    bitCount: 3
  - name: Padding
    bitCount: 5
  - name: Rehit Rate (per fighter)
    bitCount: 8
  - name: Timed Rehit on Non-Fighter Enabled
    bitCount: 1
    enums:
    - false
    - true
  - name: Timed Rehit on Fighter Enabled
    bitCount: 1
    enums:
    - false
    - true
  - name: Timed Rehit on Shield Enabled
    bitCount: 1
    enums:
    - false
    - true
  - name: Padding
    bitCount: 5
]#

import geckon

const SubactionDataLength = 0x4

defineCodes:
    createCode "Set Special Flags for Fighter Hitboxes":
        description "Enable special flags from item hitboxes"
        authors "sushie"
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

        # Reset Hit Players for Fighter Hitboxes
        patchInsertAsm "8006c9cc":
            mr r3, r29
            ResetAllHitPlayers:
                # inputs
                # r3 = fighter gobj
                %backup
                li r30, 0
                mulli r0, r30, 312
                lwz r3, 0x2C(r3) # fighter data
                add r31, r3, r0
                Loop:
                    addi r3, r31, 2324
                    %branchLink("0x80008a5c") # reset hit players
                    addi r30, r30, 1
                    cmplwi r30, 4
                    addi r31, r31, 312
                %`blt+`(Loop)
                %restore
            
            Exit:
                mr r3, r29

        # Enable Rehit Rate on Fighter Hitboxes Vs Players
        patchInsertAsm "80077230":
            # r27 = hit struct
            lbz r4, 0x41(r27)
            %`rlwinm.`(r4, r4, 30, 31, 31) # 0x4
            li r4, 0 # orig code line
            beq Exit # no timed rehit on fighters
            li r4, 5 
            Exit:
                %emptyBlock

        # Enable Rehit Rate on Fighter Hitboxes Vs Shields
        patchInsertAsm "80076d04":
            # r30 = hit struct
            lbz r4, 0x41(r30)
            %`rlwinm.`(r4, r4, 31, 31, 31) # 0x2
            li r4, 1 # orig code line
            beq Exit # no timed rehit on shields
            li r4, 2
            Exit:
                %emptyBlock

        # Enable Rehit Rate on Fighter Hitboxes Vs Non-Fighters
        patchInsertAsm "8027058c":
            # r26 = hit struct
            lbz r5, 0x41(r26)
            %`rlwinm.`(r5, r5, 29, 31, 31) # 0x8
            li r5, 0 # orig code line
            beq Exit # no timed rehit on non-fighters
            li r5, 8
            Exit:
                %emptyBlock

        # Patch for FastForwardSubactionPointer2
        patchInsertAsm "80073578":
           # fixes a crash with Kirby when using inhale with a custom subaction event
           # r4 = current subaction ptr
            cmpwi r28, 0x3D # Hitbox Extension Custom ID
            bne OriginalExit
            addi r4, r4, {SubactionDataLength}
            stw r4, 0x8(r29)
            %branch("0x80073588")
            OriginalExit:
                lbz r0, -0xA(r3)

        # Subaction Event Parsing (0xF5)
        patchInsertAsm "80073314":
            cmpwi r28, 0x3D
            %`bne+`(OriginalExit)
            # r27 = item/fighter gobj
            # r29 = script struct ptr
            # r30 = item/fighter data            

            lwz r3, 0x8(r29) # load current subaction ptr
            lbz r4, 0x1(r3)
            rlwinm r4, r4, 27, 29, 31 # 0xE0 hitbox id

            # get hitbox struct from ID
            mulli r4, r4, 312
            addi r4, r4, 2324
            add r4, r30, r4

            # r4 contains FtHit struct
            # rehit rate
            lhz r5, 0x40(r4)
            lbz r6, 0x2(r3) # load rehit rate
            rlwimi r5, r6, 4, 20, 27
            sth r5, 0x40(r4)
            # timed rehit on non-fighter
            lbz r5, 0x41(r4)
            lbz r6, 0x3(r3)
            rlwimi r5, r6, 28, 28, 28 # 0x80
            stb r5, 0x41(r4)
            # timed rehit on fighter
            lbz r5, 0x41(r4)
            lbz r6, 0x3(r3)
            rlwimi r5, r6, 28, 29, 29 # 0x40
            stb r5, 0x41(r4)
            # timed rehit on shield
            lbz r5, 0x41(r4)
            lbz r6, 0x3(r3)
            rlwimi r5, r6, 28, 30, 30 # 0x20
            stb r5, 0x41(r4)
            Exit:
                addi r3, r3, {SubactionDataLength}
                stw r3, 0x8(r29)

            %branch("0x8007332c")
            OriginalExit:
                add r3, r31, r0 # original code line
        
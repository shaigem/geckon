import geckon, ../melee

#[ #                b Exit
#            Item:
#                lwz r3, 0x2C(r3) # load item data
#                lwz r3, 0x518(r3) # load fighter
#                cmpwi r3, 0x0
#                beq Exit
#                b Fighter 
#            cmpwi r29, 0x6
#            beq Item]#

# r4 is % to heal
# has gfx
const 
    FuncHealPercent = "0x8006cf5c"
const 
    RegisterVictimData = r30
    RegisterSourceData = r29

defineCodes:
    createCode "Leech Mode - Heal on Every Hit":
        authors "Ronnie"
        description "You heal every direct hit you deal"
        patchInsertAsm "8006d43c":
            # r29 and r6 is free
            lwz {RegisterSourceData}, 0x1868({RegisterVictimData}) # load source of damage gobj
            lhz r3, 0x0({RegisterSourceData}) # check if gobj is player kind
            cmpwi r3, 0x4
            beq Fighter
            b Exit

            Fighter:
                lwz {RegisterSourceData}, 0x2C({RegisterSourceData}) # load fighter data for source
                # Check if attacker and source fighters are on the same team
                # We do not want to heal if they are on the same

                SameTeamCheck:
                    %branchToSameTeamCheck(
                        playerOneData = 
                    (ppc do:
                        mr r3, {RegisterSourceData}
                    ), playerTwoData = 
                    (ppc do: 
                        mr r4, {RegisterVictimData}
                        ), result = 
                    (ppc do:
                        cmpwi r3, 1 # if on same team, do not heal and Exit
                        beq Exit
                        ))
                Heal:
                    # Now heal the source player
                    lwz r3, 0x183C({RegisterVictimData}) # load applied damage from victim
                    # Check if source is dead (stamina_dead 0 HP)
                    lbz r4, 0x2224({RegisterSourceData})
                    "rlwinm." r4, r4, 27, 31, 31
                    bne Exit # if stamina_dead, Exit
                    # Heal source player with no GFX
                    lwz r4, 0x18F0({RegisterSourceData}) # variable containing remaining damage to heal
                    add r4, r4, r3 # add the applied damage to heal
                    stw r4, 0x18F0({RegisterSourceData}) # store it back to the remaining damage to heal variable

            Exit:
                lwz r29, 0x183C(r30) # original code line

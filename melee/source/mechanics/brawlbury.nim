import geckon

const
    MaxUnburyKnockbackUnits = 100

const 
    RegisterFighterData = r29
    OriginalBuryCheckAddress = "0x8008ecd4"

const 
    Cape = 0xA
    Grounded = 0x9

const
    BuryWaitActionStateId = 295

defineCodes:
    createCode "Brawl Bury Mechanics v1.0.4":
        authors "Ronnie"
        description "Strong hits unburies players like in Brawl"
        patchInsertAsm "8008ecbc":
            # Check if we are in a flinchless state
            %`bne-`(CheckInBuryWaitState) # we are in flinchless state, so check if we are in a bury action state
            b NotInBury # exit as if we are not in a flinchless state

            CheckInBuryWaitState:
                lwz r3, 0x10({RegisterFighterData}) # load current action state ID
                cmpwi r3, {BuryWaitActionStateId}
                %`bne-`(OriginalBuryCheck) # if not in bury wait A/S, go back to the original check function
            
            # If in bury, check if knockback is strong enough to unbury the player
            # Free to use r3 here but must restore if branch to NotInBury
            InBury:

                HitEffectChecks:
                    # If hit is another Grounded/Bury hit OR Cape,
                    # Do not unbury and go to the original bury check
                    lwz r3, 0x1860({RegisterFighterData}) # load effect type
                    # Check if grounded move
                    cmpwi r3, {Grounded}
                    beq OriginalBuryCheck
                    # If not grounded move, check if it's a cape move
                    cmpwi r3, {Cape}
                    beq OriginalBuryCheck

                # Now we check the knockback and see if we should unbury
                block knockbackChecks:
                    const 
                        RegisterForceApplied = f0
                        RegisterMaxUnitsToCheck = f1
                    # f0 = current hit's knockback/force_applied
                    # f1 = maximum knockback units to unbury
                    ppc:
                        lfs {RegisterForceApplied}, 0x1850({RegisterFighterData}) # load force_applied
                        # Load our maximum knockback units constant
                        bl Constants
                        mflr r3
                        lfs {RegisterMaxUnitsToCheck}, 0x0(r3)
                        # If the current hit's applied knockback is greater than and
                        # not equals to the MaxUnburyKnockbackUnits,
                        # unbury the player
                        fcmpo cr0, f0, f1
                        ble OriginalBuryCheck # not enough knockback, so don't unbury

                Unbury:
                    b NotInBury # treat the hit as if the player isn't flinchless

            OriginalBuryCheck:
                %branch(OriginalBuryCheckAddress)
            
            Constants:
                blrl
                %`.float`(MaxUnburyKnockbackUnits) # units of knockback
                %`.align`(2)
            
            NotInBury:
                lbz r3, 0x2220({RegisterFighterData}) # restore r3
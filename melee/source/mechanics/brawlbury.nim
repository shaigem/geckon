import geckon

const
    MaxUnburyKnockbackUnits = 100

const 
    RegisterFighterData = r29
    OriginalBuryCheckAddress = "0x8008ecd4"

const 
    Cape = 0xA
    Grounded = 0x9

defineCodes:
    createCode "Brawl Bury Mechanics":
        authors "Ronnie"
        description "Strong hits unburies players like in Brawl"
        patchInsertAsm "8008ecbc":
            # TODO this breaks grabs as well, CHECK IF IN BURY A/S INSTEAD
            # Check if in bury
            %`bne-`(InBury)
            b NotInBury # exit if not in bury
            
            # If in bury, check if knockback is strong enough to unbury the player
            # Free to use r3 here but MUST restore after
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
                    lbz r3, 0x2220({RegisterFighterData}) # restore r3
                    b NotInBury # treat the hit as if the player isn't buried

            OriginalBuryCheck:
                %branch(OriginalBuryCheckAddress)
            
            Constants:
                blrl
                %`.float`(MaxUnburyKnockbackUnits) # units of knockback
                %`.align`(2)
            
            NotInBury:
                %emptyBlock
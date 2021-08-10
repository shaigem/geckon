import geckon, ../melee

const 
    MaxAngle = 362

defineCodes:
    createCode "Random Knockback Angles":
        authors "Ronnie"
        description "Every hit has a random angle"

        # Random angle for Projectiles
        patchInsertAsm "802792e4":
            # Backup r0, r4 and r5 manually
            {backup}
            mr r31, r0
            mr r30, r4
            mr r29, r5
            # Get our random angle (from 0 to MaxAngle) into r3
            {hsdRandi(max = MaxAngle, inclusive = true)}
            stw r3, 0x0020(r29) # original code line
            # Restore r0, r4 and r5
            mr r0, r31
            mr r4, r30
            mr r29, r5
            {restore}
             
        # Random angle for Normal Hitboxes
        patchInsertAsm "8007aca0":
            # Backup r0, r3 and r5 manually
            {backup}
            mr r31, r0
            mr r30, r3
            mr r29, r5
            # Get our random angle (from 0 to MaxAngle) into r3
            {hsdRandi(max = MaxAngle, inclusive = true)}
            # Set r4 = r3 
            mr r4, r3
            # restore r0, r3 and r5 manually
            mr r0, r31
            mr r3, r30
            mr r5, r29
            {restore}
            cmplwi r4, 361 # original code line


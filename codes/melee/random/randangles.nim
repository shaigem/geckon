import geckon, ../melee

const 
    MaxAngle = 362

defineCodes:
    createCode "Random Knockback Angles":
        authors "Ronnie"
        description "Every hit has a random angle"

        # Random angle for Projectiles
        patchInsertAsm "802792e4":
            # Backup r0, r4 and r5
            stwu r1, -16(r1)
            stw r4, 0x4(r1)
            stw r0, 0x8(r1)
            stw r5, 0xC(r1)
            # Get our random angle (from 0 to MaxAngle) into r3
            {hsdRandi(max = MaxAngle, inclusive = true)}
            stw r3, 0x0020(r29) # original code line
            # Restore r0, r4 and r5
            lwz r5, 0xC(r1)
            lwz r0, 0x8(r1)
            lwz r4, 0x4(r1)
            addi r1, r1, 0x10
            
        # Random angle for Normal Hitboxes
        patchInsertAsm "8007aca0":
            # backup r0, r3 and r5
            stwu r1, -16(r1)
            stw r3, 0x4(r1)
            stw r0, 0x8(r1)
            stw r5, 0xC(r1)
            # Get our random angle (from 0 to MaxAngle) into r3
            {hsdRandi(max = MaxAngle, inclusive = true)}
            # Set r4 = r3
            mr r4, r3
            # restore r0, r3 and r5
            lwz r5, 0xC(r1)
            lwz r0, 0x8(r1)
            lwz r3, 0x4(r1)
            addi r1, r1, 0x10
            # Call the original code line and exit
            cmplwi r4, 361

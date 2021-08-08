import geckon, ../melee

const 
    OriginalCodeLine = ppc: stw r0, 0x0004 (r31)
    MaxAngle = 362
    RegisterRandomAngle = $Register.r3
    RegisterAngleResult = $Register.r0

defineCodes:
    createCode "Random Knockback Angles":
        authors "Ronnie"
        description "Every hit has a random angle"
        patchInsertAsm "8007a934":
            # Get our random angle (from 0 to MaxAngle) into r3
            {hsdRandi(max = MaxAngle, inclusive = true)}
            # Set r0 = r3
            mr {RegisterAngleResult}, {RegisterRandomAngle}
            # Call the original code line and exit
            {OriginalCodeLine}


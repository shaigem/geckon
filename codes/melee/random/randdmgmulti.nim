import geckon, ../melee

const
    MaxMultiplier = 10.0
    OriginalCodeLine = ppc: lwz r0, 0x002C(sp)

defineCodes:
    createCode "Random Damage Multiplier":
        authors "Ronnie"
        description "Every hit has a random multiplier applied to it"
        patchInsertAsm "80089284":
            # free to use r0 and f31
            
            # Get random number in r3
            {hsdRandi(max = (MaxMultiplier * 10).int, inclusive = true)}
            # Cast to float and place it into f31
            sth r3, 0x14(sp)
            psq_l f31, 0x14(sp), 1, 5
            # Multiply damage by multiplier
            ps_mul f31, f1, f31 # f31 now has our new damage
            # Load our divisor (10.0)
            bl DivisorConstant
            mflr r3
            lfs f1, 0x0(r3) # f1 is free to use since f31 has our new damage
            # Divide our new damage by 10
            ps_div f31, f31, f1
            # Store result in f1 to ensure 64-bit double
            fmr f1, f31
            b OriginalExit
            
            DivisorConstant:
                blrl
                ".float"10.0

            OriginalExit:            
                {OriginalCodeLine}


        
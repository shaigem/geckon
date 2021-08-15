import geckon, ../melee

const
    MaxMultiplier = 10.0
    Divisor = 10
    OriginalCodeLine = ppc: lwz r0, 0x002C(sp)

defineCodes:
    createCode "Random Damage Multiplier":
        authors "Ronnie"
        description "Every hit has a random multiplier applied to it"
        patchInsertAsm "80089284":
            # free to use: f31, r0, r30, r31
            %hsdRandi(max = (MaxMultiplier * 10).int, inclusive = true)
            # Cast the Divisor and our multiplier as floats into f31 
            addis r3, r3, {Divisor}
            stw r3, 0x14(sp)
            psq_l f31, 0x14(sp), 0, 5
            # Multiply damage by multiplier
            ps_muls1 f1, f1, f31
            # Divide our new damage by 10 and store in f1
            ps_div f1, f1, f31
            b OriginalExit
            
            OriginalExit:            
                %OriginalCodeLine
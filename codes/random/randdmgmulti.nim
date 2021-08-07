import geckon, ../common/melee

# TODO make this a common function?
proc defineIntToFloat(): string =
    ppc:
        IntToFloat:
            mflr r0
            stw r0, 0x4(r1)
            stwu r1, -0x100(r1)
            stmw r20, 0x8(r1)
            stfs f2, 0x38(r1)

            lis r0, 0x4330
            lfd f2, -0x6758 (rtoc)
            xoris r3, r3, 0x8000
            stw r0, 0xF0(sp)
            stw r3, 0xF4(sp)
            lfd f1, 0xF0(sp)
            fsubs f1, f1, f2

            lfs f2, 0x38(r1)
            lmw r20, 0x8(r1)
            lwz r0, 0x104(r1)
            addi r1, r1, 0x100
            mtlr r0
            blr

const
    FuncIntToFloat = "IntToFloat"
    MultiplierMax = 40.0 # up to 40 times the damage
    RegisterMultiplier = f2
    RegisterRandomMultiplier = f1
    OriginalCodeLine = ppc:
        mr r30, r3

defineCodes:
    createCode "Random Damage Multiplier (Projectiles)":
        authors "Odante"
        description "Every projectile hit has a random damage multiplier applied to it"

        patchInsertAsm "802724A8":
            {OriginalCodeLine}

            # get random multiplier in r3
            {hsdRandi(max = (MultiplierMax * 10).int, inclusive = true)}
            # multiplier shouldn't be 0
            CheckIfValidMultiplier:
                cmpwi r3, 0
                ble Exit
                bl {FuncIntToFloat} # convert to float, result is now in f1

            # divide multiplier by 10
            # safe to use f2 because we are going to overwrite it anyways
            bl MultiplierFloats
            mflr r3
            # load the float 10 into f2
            lfs {RegisterMultiplier}, DivisorOffset(r3)
            # divide our random multiplier (f1) by 10 (f2) and store it back into f2
            fdivs {RegisterMultiplier}, {RegisterRandomMultiplier}, {RegisterMultiplier}
            b Exit

            MultiplierFloats:
                blrl
                ".set"DivisorOffset, 0x0
                ".float"10.0

            {defineIntToFloat()}

            Exit:
                mr r3, r30 # restore r3

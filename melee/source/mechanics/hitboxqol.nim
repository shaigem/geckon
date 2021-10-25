import geckon

defineCodes:
    createCode "Hitbox Command Fix Hit Only Grabbed Target":
        description "Fixes bit 19 of the Hitbox CMD to hit only the grabbed target"
        patchWrite32Bits "80071570":
            lbz r3, -0x0013(r3)
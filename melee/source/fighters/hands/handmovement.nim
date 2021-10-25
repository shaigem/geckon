import geckon

defineCodes:
    createCode "Mh & Ch Brawl Movement":

        # Fixed movement speed when using the generic move function
        patchWrite32Bits "8015bf20":
            fmuls f0, f0, f30
        patchWrite32Bits "8015bf2c":
            fmuls f0, f0, f30
        patchWrite32Bits "8015bf38":
            fmuls f0, f0, f30
        
        # Fix for CH's poke targeting move
        patchWrite32Bits "801580f0":
            nop
        # Fix for CH's grab targeting move
        patchWrite32Bits "80158da4":
            nop
        # CH won't move back to start pos when player gets out of grab    
        patchWrite32Bits "80159244":
            nop

        # Fix for MH's poke targeting move
        patchWrite32Bits "80152b78":
            nop
        # Fix for MH's gun targeting move
        patchWrite32Bits "80153378":
            nop
        # Fix for MH's grab targeting move
        patchWrite32Bits "80154548":
            nop
        # MH won't move back to start pos when player gets out of grab    
        patchWrite32Bits "801549e8":
            nop
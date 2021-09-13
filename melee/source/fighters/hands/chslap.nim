import geckon

defineCodes:

    createCode "Crazy Hand Slap Fixes":

        patchInsertAsm "80156b54":
            # applies to player inputting slap move
            # make ch slap instantly, no need to move in place
            lis r3, 0x8015
            addi r4, r3, 28524
            addi r3, r31, 0
            %branchLink("0x80156F6C")
            %branch("0x80156b7c")

        patchInsertAsm "801566b4":
            # applies to CPU deciding to slap
            # make ch slap instantly, no need to move in place
            lis r3, 0x8015
            addi r4, r3, 28524
            addi r3, r31, 0
            %branchLink("0x80156F6C")
            %branch("0x801566dc")
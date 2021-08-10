import geckon

const LaserCodeLine = ppc: li r7, 0x7F

defineCodes:
    createCode "Crazy Hand Uses His Own Lasers":
        description "Can use his lasers without Master Hand in a match"
        patchWrite32Bits "80158584":
            {LaserCodeLine}
        patchWrite32Bits "801585B8":
            {LaserCodeLine}
        patchWrite32Bits "801585EC":
            {LaserCodeLine}
        patchWrite32Bits "80158620":
            {LaserCodeLine}

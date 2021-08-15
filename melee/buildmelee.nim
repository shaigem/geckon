import geckon

const AllCodes = importFrom "./source/"

build:
    includeAllCodes AllCodes
    keepObjFiles = false
    output:
        writeCodesToFile "./out/melee.txt"
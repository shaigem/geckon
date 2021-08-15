import geckon

const AllCodes = importFrom "./codes/"

build:
    includeAllCodes AllCodes
    keepObjFiles = false
    output:
        writeCodesToFile "./out/melee.txt"
import geckon

const AllCodes = importFrom "./codes/"

build:
    includeAllCodes AllCodes
    output:
        writeCodesToFile "./out/melee.txt"
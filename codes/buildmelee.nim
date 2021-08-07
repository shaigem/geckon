import geckon, melee / [fighters/hands/chfixlaser, random/randdmgmulti]

build:
    importAll randdmgmulti
    importAll chfixlaser

    output:
        writeCodesToFile "./melee.txt"
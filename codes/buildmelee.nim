import geckon, melee / [fighters/hands/chfixlaser, random/randdmgmulti], melee/random/randangles

build:
    importAll randdmgmulti
    importAll chfixlaser
    importall randangles

    output:
        writeCodesToFile "./melee.txt"
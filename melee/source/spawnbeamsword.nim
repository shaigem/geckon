import geckon

const 
    FuncEntityItemSpawn = "0x80268B18"
    FuncGiveItemToPlayer = "0x800948a8"
    BeamSwordId = 0xC

defineCodes:
    createCode "Spawn Beam Sword P1":
        description "Spawns a beam sword for player 1"
        authors "Ronnie"
        patchInsertAsm "8006938c":
            %backup

            lbz r3, 0xC(r3) # ply index
            cmpwi r3, 0
            bne Exit


            addi r3, sp, 0x80
            li r4, 0
            stw r4, 0(r3)
            stw r4, 0x4(r3)
            li r4, {BeamSwordId}
            stw r4, 0x8(r3)

            lfs f31, -0x2858(rtoc) # z
            lfs f30, 0xB0(r31) # x
            lfs f29, 0xB4(r31) # y

            stfs f30, 0x14(r3) # store x
            stfs f29, 0x18(r3) # store y
            stfs f31, 0x1C(r3) # store z

            stfs f30, 0x20(r3) # store x
            stfs f29, 0x24(r3) # store y
            stfs f31, 0x28(r3) # store z

            stfs f31, 0x2C(r3) # store unk
            stfs f31, 0x30(r3) # store unk
            stfs f31, 0x34(r3)
            stfs f31, 0x38(r3)

            li r4, 0
            sth r4, 0x3C(r3)
            %branchLink(FuncEntityItemSpawn)
            lwz r3, 0x2C(r3)
            lwz r4, 0x4(r3)
            mr r3, r31
            %branchLink(FuncGiveItemToPlayer)
            
            Exit:
                %restore
                mr r3, r31
                lwz r0, 0x004C(sp) # original code line
            


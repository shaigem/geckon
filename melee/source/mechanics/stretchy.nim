import geckon

defineCodes:
    createCode "Stretchy":
        description ""
        patchInsertAsm "8007adb0":
            # on create hitbox position
            # calculate position with offset of 0
            li r0, 0
            stw r0, 0x10(sp)
            stw r0, 0x14(sp)
            stw r0, 0x18(sp)
            lwz r3, 0x48(r31) # bone jobj

        patchInsertAsm "8007ae5c":
            # on update hitbox position
            # calculate position with offset of 0
            li r0, 0
            stw r0, 0x10(sp)
            stw r0, 0x14(sp)
            stw r0, 0x18(sp)
            lwz r3, 0x48(r31) # bone jobj


        patchInsertAsm "8007addc":

            lwz r3, 0x10(r31)
            lwz r4, 0x14(r31)

            stw r3, 0x10(sp)
            stw r4, 0x14(sp)

            lwz r4, 0x18(r31)
            stw r4, 0x18(sp)

            lwz r3, 0x48(r31) # bone jobj
            addi r4, sp, 16 # offset ptr
            addi r5, r31, 0x58
            %branchLink("0x8000B1CC")



        patchInsertAsm "8007ae00":

            mr r6, r3 # backup r3

            lwz r3, 0x10(r31)
            lwz r4, 0x14(r31)

            stw r3, 0x10(sp)
            stw r4, 0x14(sp)

            lwz r4, 0x18(r31)
            stw r4, 0x18(sp)

            lwz r3, 0x48(r31) # bone jobj
            addi r4, sp, 16 # offset ptr
            addi r5, r31, 0x58
            %branchLink("0x8000B1CC")

            mr r3, r6

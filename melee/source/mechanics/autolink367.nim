import geckon

const 
    Angle = 367
    Steps = 0.08
    MinStepDistance = 0.16

const 
    PSVecMagFunc = "0x80342dfc"
    SubtractVector3DFunc = "0x8000D4F8"
    Atan2Func = "0x80022c30"

defineCodes:
    createCode "Autolink 367":
        description "Special angle that tries to keep victims in"
        authors "sushie", "rmn"
        
        # autolink 367
        patchInsertAsm "8007a868":
            # 1. defender is moved towards hitbox pos
            # 2. defender is moved in the direction the attacker is moving to
            # 3. knockback is adjusted based on distance between hitbox pos and defender
            # r3 = hit struct
            # r15 = attacker data
            # r25 = defender data
            # r17 = damage source?

            # first check hitbox angle
            lwz r0, 0x20(r3) # angle of hit struct
            cmplwi r0, {Angle}
            bne OriginalExit # if not autolink angle, exit

            # TODO should grounded defenders take a set angle of 80?
            mr r6, r3 # backup hit struct to r6
            bl Constants
            mflr r3
            lfs f1, 0(r3)
            lfs f2, 0x4(r3)
            addi r4, r6, 0x4C # point to pos of hitbox
            lwz r3, 0(r25) # defender gobj
            bl MoveTowardsPoint
            # now f1 = next step y
            # f2 = next step x
            # check for reverse hits
            lfs f0, -0x7700(rtoc) # 0.0
            lfs f5, 0x4C(r6) # hitbox x
            lfs f6, 0xB0(r25) # Defender x
            fsubs f5, f6, f5
            fcmpo cr0, f5, f0
            %`bge+`(CheckReverseForAtkDef)
            fneg f2, f2 # negate the next step x
            CheckReverseForAtkDef:
                    lfs f3, 0xCC(r15) # attacker y vel
                    lfs f4, 0xC8(r15) # attacker x vel
                    lfs f5, 0xB0(r15) # attacker x
                    lfs f6, 0xB0(r25) # defender x
                    fsubs f5, f6, f5 # def x - atk x
                    fcmpo cr0, f5, f0
                    %`bge+`(CalculateDirAndKb)
                    fneg f4, f4 # negate attacker x vel
            CalculateDirAndKb:
                fadds f1, f3, f1 # attacker y vel + next step y
                fadds f2, f4, f2 # attacker x vel + next step x
                CalcKb:
                    stwu sp, -0x20(sp)
                    addi r3, sp, 0x14
                    stfs f0, 0x1C(sp) # z
                    stfs f1, 0x18(sp) # y
                    stfs f2, 0x14(sp) # x
                    %branchLink(PSVecMagFunc) # PSVecMag
                    fadds f26, f26, f1 # add old kb value with our new one
                    # restore f1 & f2
                    lfs f1, 0x18(sp) # y
                    lfs f2, 0x14(sp) # x
                    addi sp, sp, 0x20
                CalcDir:
                    %branchLink(Atan2Func) # atan2
                    lfs f0, -0x76C4(rtoc) # 180/PI convert radian to degrees
                    fmuls f25, f0, f1
                    fctiwz f0, f25
                    stfs f24, 0(r31)
                    stfd f0, 0x210(sp)
                    # make angle positive for meteor canceling
                    lwz r3, 0x214(sp)
                    cmpwi r3, 0
                    bge Epilog # angle is positive
                    addi r3, r3, 360 # add 360 to get the postivie equivalent

            Epilog:
                stw r3, 0x4(r31) # store our new angle
                %branch("0x8007a938")

            Constants:
                blrl
                %`.float`(MinStepDistance) # minimum end step
                %`.float`(Steps) # step (was 0.08)

            MoveTowardsPoint:
                # linear interop
                # inputs
                # f1 = minimum end step
                # f2 = steps
                # r3 = fighter GOBJ (start)
                # r4 = end pos ptr
                # outputs
                # f1 = y
                # f2 = x
                mflr r0
                stw r0, 4(r1)
                stwu r1, -0x58(r1)
                stfd f31, 0x50(r1)
                fmr f31, f2
                stfd f30, 0x48(r1)
                fmr f30, f1
                stfd f29, 0x40(r1)
                stw r31, 0x3c(r1)
                stw r30, 0x38(r1)
                addi r5, r1, 0x2c
                lwz r31, 0x2c(r3)
                addi r3, r4, 0
                addi r4, r31, 0xB0
                %branchLink(SubtractVector3DFunc)
                addi r3, sp, 0x2C
                %branchLink(PSVecMagFunc)
                fmr f29, f1
                lbl_8015BEF8:
                    fcmpo cr0, f29, f30
                    bge lbl_8015BF0C
                    b MoveTowardsPointEpilog
                lbl_8015BF0C:
                    addi r3, r1, 0x2c
                    %branchLink("0x8000D2EC")
                    fmuls f1, f29, f31
                    lfs f0, 0x2c(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x2c(r1)
                    lfs f0, 0x30(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x30(r1)
                    lfs f0, 0x34(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x34(r1)
                MoveTowardsPointEpilog:
                    lfs f2, 0x2c(r1)
                    lfs f1, 0x30(r1)
                    lwz r0, 0x5c(r1)
                    lfd f31, 0x50(r1)
                    lfd f30, 0x48(r1)
                    lfd f29, 0x40(r1)
                    lwz r31, 0x3c(r1)
                    lwz r30, 0x38(r1)
                    addi r1, r1, 0x58
                    mtlr r0
                    blr

            OriginalExit:
                lwz r0, 0x20(r3)

#[ 
        patchInsertAsm "8007a868":
            # r3 = Hit struct
            # r15 = attacker data
            # r25 = defender data
            # r17 = damage source? (0x10 = Collided Ft/It Hurt) 

            lwz r0, 0x20(r3) # hitbox angle

            cmplwi r0, 367
            bne OriginalExit
#[ 
            lfs f1, 0x50(r3) # hitbox y pos
            lfs f2, 0x4C(r3) # hitbox x pos
            lfs f3, 0xB0(r25) # hitbox y coll pos
            lfs f4, 0xB4(r25) # hitbox x coll pos

            fsubs f1, f1, f3 # y pos - coll y pos
            fsubs f2, f2, f4 # x pos - coll x pos
 ]#

            # check if defender is grounded
            # if grounded, set angle to 80 and do not adjust for speed
            bl Data
            mflr r5
            lwz r4, 0xE0(r25) # air state
            cmpwi r4, 0
            bne CalculateVelHitbox
            lfs f0, 0x10(r5)
            fmr f25, f0
            b OriginalExit

            CalculateVelHitbox:
                mr r6, r3
                lfs f1, 0(r5)
                lfs f2, 0x4(r5)
                addi r4, r3, 0x4C # pos of hitbox
                lwz r3, 0(r25)
                bl ToPointFunc

                lfs f5, 0x4C(r6) # hitbox x
                lfs f6, 0xB0(r25) # Defender x
                fsubs f5, f6, f5
                lfs f0, -0x7700(rtoc) # 0
                fcmpo cr0, f5, f0
                %`bge+`(CheckReverseForAttackerDefender) # override reverse hits
                fneg f2, f2

                CheckReverseForAttackerDefender:
                    lfs f3, 0xCC(r15) # attacker y vel
                    lfs f4, 0xC8(r15) # x vel
              
                lfs f5, 0xB0(r15) # Attacker x
                lfs f6, 0xB0(r25) # Defender x
                fsubs f5, f6, f5
                lfs f0, -0x7700(rtoc) # 0
                fcmpo cr0, f5, f0
                %`bge+`(NotReverse) # override reverse hits
                lfs f0, -0x76F0(rtoc) # -1
                fmuls f4, f0, f4 # fneg?
                NotReverse:
                    fadds f1, f3, f1
                    fadds f2, f4, f2

                    fmr f3, f2
                    fmr f4, f1
                    fmuls f3, f3, f3 # vel x squared
                    fmuls f4, f4, f4 # vel y squared
                    fadds f3, f4, f3 # add velocities together
                    frsqrte f4, f3 # sqrt
                    # f4 = recipricol = f1
                    # f29 = f3
                    # f3 = f6
                    # f2 = f5

                    lfd f6, -0x57D8(rtoc)
                    lfd f5, -0x57D0(rtoc)
                    fmul f0, f4, f4
                    fmul f4, f6, f4
                    fnmsub f0, f3, f0, f5

                    fmul f4, f4, f0
                    fmul f0, f4, f4
                    fmul f4, f6, f4
                    fnmsub f0, f3, f0, f5

                    fmul f4, f4, f0
                    fmul f0, f4, f4
                    fmul f4, f6, f4
                    fnmsub f0, f3, f0, f5

                    fmul f0, f4, f0
                    fmul f0, f3, f0
                    frsp f0, f0
                    fmr f3, f0
                    fadds f26, f26, f3 # 0.5 * velocity

#                    stfs f1, 0x90(r25)
#                    stfs f2, 0x8C(r25)
#            %branchLink("0x80022c30") # atan2

#            fmr f3, f1 # save atan result


            %branchLink("0x80022c30")
            
#            fsubs f1, f3, f1

            lfs f0, -0x76c4(rtoc) # 180/pi. Convert radians to degrees
            fmuls f25, f0, f1
            fctiwz f0, f25
            stfs f24, 0(r31)
            stfd f0, 0x210(sp)
            lwz r3, 0x214(sp)
            cmpwi r3, 0
            bge Exit # angle is positive
            addi r3, r3, 360

            Exit:
                stw r3, 0x4(r31)
                %branch("0x8007a938")

#[ f1 = speed stuff
   f2 = speed stuff
   r3 = our gobj
   r4 = vec pos of where to go ]#
            ToPointFunc:
                mflr r0
                stw r0, 4(r1)
                stwu r1, -0x58(r1)
                stfd f31, 0x50(r1)
                fmr f31, f2
                stfd f30, 0x48(r1)
                fmr f30, f1
                stfd f29, 0x40(r1)
                stw r31, 0x3c(r1)
                stw r30, 0x38(r1)
#                addi r30, r5, 0
                addi r5, r1, 0x2c
                lwz r31, 0x2c(r3)
                addi r3, r4, 0
                addi r4, r31, 0xb0
                %branchLink("0x8000D4F8")
                #bl func_8000D4F8
                lfs f1, 0x2c(r1)
                lfs f0, 0x30(r1)
                fmuls f2, f1, f1
                lfs f3, 0x34(r1)
                fmuls f1, f0, f0
                lfs f0, -0x57E8(rtoc)
                fmuls f3, f3, f3
                fadds f1, f2, f1
                fadds f29, f3, f1
                fcmpo cr0, f29, f0
                ble lbl_8015BEF8
                frsqrte f1, f29
                lfd f3, -0x57D8(rtoc)
                lfd f2, -0x57D0(rtoc)
                fmul f0, f1, f1
                fmul f1, f3, f1
                fnmsub f0, f29, f0, f2
                fmul f1, f1, f0
                fmul f0, f1, f1
                fmul f1, f3, f1
                fnmsub f0, f29, f0, f2
                fmul f1, f1, f0
                fmul f0, f1, f1
                fmul f1, f3, f1
                fnmsub f0, f29, f0, f2
                fmul f0, f1, f0
                fmul f0, f29, f0
                frsp f0, f0
                stfs f0, 0x24(r1)
                lfs f29, 0x24(r1)
                lbl_8015BEF8:
                    fcmpo cr0, f29, f30
                    bge lbl_8015BF0C
                    b lbl_8015BF40
                lbl_8015BF0C:
#                    stfs f29, 0(r30)
                    addi r3, r1, 0x2c
                    %branchLink("0x8000D2EC")
#                    bl func_8000D2EC
                    fmuls f1, f29, f31
                    lfs f0, 0x2c(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x2c(r1)
                    lfs f0, 0x30(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x30(r1)
                    lfs f0, 0x34(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x34(r1)
                lbl_8015BF40:
                    lfs f2, 0x2c(r1)
#                    stfs f0, 0x8c(r31)
                    lfs f1, 0x30(r1)
#                    stfs f0, 0x90(r31)
                    lwz r0, 0x5c(r1)
                    lfd f31, 0x50(r1)
                    lfd f30, 0x48(r1)
                    lfd f29, 0x40(r1)
                    lwz r31, 0x3c(r1)
                    lwz r30, 0x38(r1)
                    addi r1, r1, 0x58
                    mtlr r0
                    blr
            Data:
                blrl
                %`.float`(0.16)
                %`.float`(0.20) # was 0.08
                %`.float`(0.50)
                %`.float`(10)
                %`.float`(80) ]#

            # two vectors
            # first = attacker's direction vector
            # second = hitbox's pos vector

#[         patchInsertAsm "8007a868":
            # r3 = Hit struct
            # r15 = attacker data
            # r25 = defender data
            # r17 = damage source? (0x10 = Collided Ft/It Hurt) 

            lwz r0, 0x20(r3) # hitbox angle


            cmplwi r0, 367
            bne OriginalExit
            bl Data
            mflr r5
            lwz r4, 0xE0(r25) # air state
            cmpwi r4, 0
            bne Hi
            lfs f0, 0x10(r5)
            fmr f25, f0
            b OriginalExit


            Hi:

                lwz r4, 0xC(r5)
                stw r4, 0x18AC(r25)
                lfs f1, 0(r5) # gotta change to 3E23D70A & 3DA3D70A
                lfs f2, 0x4(r5)
                addi r4, r15, 0xb0 # TODO make target the fthit pos_prev?
                lwz r3, 0(r25)
                bl ToPointFunc

            lfs f1, 0xCC(r15) # attacker y vel
            lfs f2, 0xC8(r15) # x vel
            lfs f3, 0xB0(r15) # Attacker x
            lfs f4, 0xB0(r25) # Defender x
            fsubs f3, f4, f3
            lfs f0, -0x7700(rtoc) # 0
            fcmpo cr0, f3, f0
            %`bge+`(not_reverse) # override reverse hits
            lfs f0, -0x76F0(rtoc) # -1
            fmuls f2, f0, f2
            not_reverse:
#            lfs f0, -0x76c4(rtoc) # 180/pi. Convert radians to degrees
#            fmuls f0, f0, f1
#            fctiwz f0, f1
                lfs f3, 0x80(r15)
                lfs f4, 0x84(r15)
                fmuls f3, f3, f3 # vel x squared
                fmuls f4, f4, f4 # vel y squared
                fadds f3, f4, f3 # add velocities together
                frsqrte f4, f3 # sqrt
                # f4 = recipricol = f1
                # f29 = f3
                # f3 = f6
                # f2 = f5

                lfd f6, -0x57D8(rtoc)
                lfd f5, -0x57D0(rtoc)
                fmul f0, f4, f4
                fmul f4, f6, f4
                fnmsub f0, f3, f0, f5

                fmul f4, f4, f0
                fmul f0, f4, f4
                fmul f4, f6, f4
                fnmsub f0, f3, f0, f5

                fmul f4, f4, f0
                fmul f0, f4, f4
                fmul f4, f6, f4
                fnmsub f0, f3, f0, f5

                fmul f0, f4, f0
                fmul f0, f3, f0
                frsp f0, f0
                fmr f3, f0
                
                lfs f4, 0x198(r15) # weight of attacker
                fmuls f3, f4, f3
                bl Data
                mflr r3
                lfs f4, 0x8(r3)
                fmuls f26, f4, f3 # 0.5 * velocity

                #lfs f4, 0x198(r15)

                %branch("0x8007a8f0", r0)


#[ f1 = speed stuff
   f2 = speed stuff
   r3 = our gobj
   r4 = vec pos of where to go ]#
            ToPointFunc:
                mflr r0
                stw r0, 4(r1)
                stwu r1, -0x58(r1)
                stfd f31, 0x50(r1)
                fmr f31, f2
                stfd f30, 0x48(r1)
                fmr f30, f1
                stfd f29, 0x40(r1)
                stw r31, 0x3c(r1)
                stw r30, 0x38(r1)
#                addi r30, r5, 0
                addi r5, r1, 0x2c
                lwz r31, 0x2c(r3)
                addi r3, r4, 0
                addi r4, r31, 0xb0
                %branchLink("0x8000D4F8")
                #bl func_8000D4F8
                lfs f1, 0x2c(r1)
                lfs f0, 0x30(r1)
                fmuls f2, f1, f1
                lfs f3, 0x34(r1)
                fmuls f1, f0, f0
                lfs f0, -0x57E8(rtoc)
                fmuls f3, f3, f3
                fadds f1, f2, f1
                fadds f29, f3, f1
                fcmpo cr0, f29, f0
                ble lbl_8015BEF8
                frsqrte f1, f29
                lfd f3, -0x57D8(rtoc)
                lfd f2, -0x57D0(rtoc)
                fmul f0, f1, f1
                fmul f1, f3, f1
                fnmsub f0, f29, f0, f2
                fmul f1, f1, f0
                fmul f0, f1, f1
                fmul f1, f3, f1
                fnmsub f0, f29, f0, f2
                fmul f1, f1, f0
                fmul f0, f1, f1
                fmul f1, f3, f1
                fnmsub f0, f29, f0, f2
                fmul f0, f1, f0
                fmul f0, f29, f0
                frsp f0, f0
                stfs f0, 0x24(r1)
                lfs f29, 0x24(r1)
                lbl_8015BEF8:
                    fcmpo cr0, f29, f30
                    bge lbl_8015BF0C
                    lfs f0, 0x1C(sp)
                    stfs f0, 0x80(r31) # TODO wrong 0x1c & 0x20
                    lfs f0, 0x20(sp)
                    stfs f0, 0x84(r31)
#                    lfs f0, -0x57E8(rtoc)
#                    stfs f0, 0(r30)
                    b lbl_8015BF40
                lbl_8015BF0C:
#                    stfs f29, 0(r30)
                    addi r3, r1, 0x2c
                    %branchLink("0x8000D2EC")
#                    bl func_8000D2EC
                    fmuls f1, f29, f31
                    lfs f0, 0x2c(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x2c(r1)
                    lfs f0, 0x30(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x30(r1)
                    lfs f0, 0x34(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x34(r1)
                lbl_8015BF40:
                    lfs f0, 0x2c(r1)
                    stfs f0, 0x8c(r31)
                    lfs f0, 0x30(r1)
                    stfs f0, 0x90(r31)
                    lwz r0, 0x5c(r1)
                    lfd f31, 0x50(r1)
                    lfd f30, 0x48(r1)
                    lfd f29, 0x40(r1)
                    lwz r31, 0x3c(r1)
                    lwz r30, 0x38(r1)
                    addi r1, r1, 0x58
                    mtlr r0
                    blr

            Data:
                blrl
                %`.float`(0.16)
                %`.float`(0.08)
                %`.float`(0.50)
                %`.float`(10)
                %`.float`(80) ]#


#[ f1 = speed stuff
   f2 = speed stuff
   r5 = ptr to boolean
   r3 = our gobj
   r4 = vec pos of where to go]#

#            fctiw f0, f1
#            stfd f0, -8(sp)
#            lwz r3, -4(sp)
#            cmpwi r3, 0 # force angle into [0, 360]
#            %`bge+`(positive_angle) # (so meteor cancelling works)
#            addi r3, r3, 360
#            positive_angle:
#                wz r4, 0xC(r17)
 #           %branch("0x8007a8f0", r0)
#            %restore

#            OriginalExit:
#                lwz r0, 0x20(r3)

# defineCodes:
#     createCode "Autolink 367 Degrees":
#         description ""
#         authors "Ronnie/sushie"
#         patchInsertAsm "8007a868":
#             # r3 = Hit struct
#             # r15 = attacker data
#             # r25 = defender data
#             # r17 = damage source? (0x10 = Collided Ft/It Hurt) 

#             lwz r0, 0x20(r3) # hitbox angle

#             cmplwi r0, 367
#             bne OriginalExit

# #            %backup

#             lfs f1, 0xCC(r15) # attacker y vel
#             lfs f2, 0xC8(r15) # x vel
#             lfs f3, 0xB0(r15) # Attacker x
#             lfs f4, 0xB0(r25) # Defender x
#             fsubs f3, f4, f3
#             lfs f0, -0x7700(rtoc) # 0
#             fcmpo cr0, f3, f0
#             %`bge+`(not_reverse) # override reverse hits
#             lfs f0, -0x76F0(rtoc) # -1
#             fmuls f2, f0, f2
#             not_reverse:
# #            lfs f0, -0x76c4(rtoc) # 180/pi. Convert radians to degrees
# #            fmuls f0, f0, f1
# #            fctiwz f0, f1
#                 lfs f3, 0x80(r15)
#                 lfs f4, 0x84(r15)
#                 fmuls f3, f3, f3 # vel x squared
#                 fmuls f4, f4, f4 # vel y squared
#                 fadds f3, f4, f3 # add velocities together
#                 frsqrte f4, f3 # sqrt
#                 # f4 = recipricol = f1
#                 # f29 = f3
#                 # f3 = f6
#                 # f2 = f5

#                 lfd f6, -0x57D8(rtoc)
#                 lfd f5, -0x57D0(rtoc)
#                 fmul f0, f4, f4
#                 fmul f4, f6, f4
#                 fnmsub f0, f3, f0, f5

#                 fmul f4, f4, f0
#                 fmul f0, f4, f4
#                 fmul f4, f6, f4
#                 fnmsub f0, f3, f0, f5

#                 fmul f4, f4, f0
#                 fmul f0, f4, f4
#                 fmul f4, f6, f4
#                 fnmsub f0, f3, f0, f5

#                 fmul f0, f4, f0
#                 fmul f0, f3, f0
#                 frsp f0, f0
#                 fmr f3, f0
                
#                 lfs f4, 0x198(r15) # weight of attacker
#                 fmuls f3, f4, f3
#                 bl Data
#                 mflr r3
#                 lfs f4, 0(r3)
#                 fmuls f26, f4, f3 # 0.5 * velocity

#                 #lfs f4, 0x198(r15)

#                 %branch("0x8007a8f0", r0)

#             Data:
#                 blrl
#                 %`.float`(0.50)


# #            fctiw f0, f1
# #            stfd f0, -8(sp)
# #            lwz r3, -4(sp)
# #            cmpwi r3, 0 # force angle into [0, 360]
# #            %`bge+`(positive_angle) # (so meteor cancelling works)
# #            addi r3, r3, 360
# #            positive_angle:
# #                wz r4, 0xC(r17)
#  #           %branch("0x8007a8f0", r0)
# #            %restore

#             OriginalExit:
#                 lwz r0, 0x20(r3)

#[ 
           ToPointFunc:
                mflr r0
                stw r0, 4(r1)
                stwu r1, -0x58(r1)
                stfd f31, 0x50(r1)
                fmr f31, f2
                stfd f30, 0x48(r1)
                fmr f30, f1
                stfd f29, 0x40(r1)
                stw r31, 0x3c(r1)
                stw r30, 0x38(r1)
                addi r30, r5, 0
                addi r5, r1, 0x2c
                lwz r31, 0x2c(r3)
                addi r3, r4, 0
                addi r4, r31, 0xb0
                %branchLink("0x8000D4F8")
                #bl func_8000D4F8
                lfs f1, 0x2c(r1)
                lfs f0, 0x30(r1)
                fmuls f2, f1, f1
                lfs f3, 0x34(r1)
                fmuls f1, f0, f0
                lfs f0, -0x57E8(rtoc)
                fmuls f3, f3, f3
                fadds f1, f2, f1
                fadds f29, f3, f1
                fcmpo cr0, f29, f0
                ble lbl_8015BEF8
                frsqrte f1, f29
                lfd f3, -0x57D8(rtoc)
                lfd f2, -0x57D0(rtoc)
                fmul f0, f1, f1
                fmul f1, f3, f1
                fnmsub f0, f29, f0, f2
                fmul f1, f1, f0
                fmul f0, f1, f1
                fmul f1, f3, f1
                fnmsub f0, f29, f0, f2
                fmul f1, f1, f0
                fmul f0, f1, f1
                fmul f1, f3, f1
                fnmsub f0, f29, f0, f2
                fmul f0, f1, f0
                fmul f0, f29, f0
                frsp f0, f0
                stfs f0, 0x24(r1)
                lfs f29, 0x24(r1)
                lbl_8015BEF8:
                    fcmpo cr0, f29, f30
                    bge lbl_8015BF0C
                    lfs f0, -0x57E8(rtoc)
                    stfs f0, 0(r30)
                    b lbl_8015BF40
                lbl_8015BF0C:
                    stfs f29, 0(r30)
                    addi r3, r1, 0x2c
                    %branchLink("0x8000D2EC")
#                    bl func_8000D2EC
                    fmuls f1, f29, f31
                    lfs f0, 0x2c(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x2c(r1)
                    lfs f0, 0x30(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x30(r1)
                    lfs f0, 0x34(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x34(r1)
                lbl_8015BF40:
                    lfs f0, 0x2c(r1)
                    stfs f0, 0x80(r31)
                    lfs f0, 0x30(r1)
                    stfs f0, 0x84(r31)
                    lwz r0, 0x5c(r1)
                    lfd f31, 0x50(r1)
                    lfd f30, 0x48(r1)
                    lfd f29, 0x40(r1)
                    lwz r31, 0x3c(r1)
                    lwz r30, 0x38(r1)
                    addi r1, r1, 0x58
                    mtlr r0
                    blr
 ]#
import unittest, ../src/geckon

suite "nim code to ppc":

    test "single instruction":
        const a =
            ppc:
                nop
        const a2 = "nop"
        check a == a2

    test "instructions with infix operator (exclude dot)":
        const a =
            ppc:
                bne- Bob
                bgt+ Bob
        const a2 = """
bne- Bob
bgt+ Bob"""
        check a == a2

    test "instructions with prefix/infix dot expr":
        const a =
            ppc:
                `rlwinm.`(r4, r4, 27, 31, 31)
                `cmpwi.`(r2, 90)
                Bob:
                    John:
                        Cat:
                            `.float`(20.0)
        const a2 = """
rlwinm. r4, r4, 27, 31, 31
cmpwi. r2, 90
Bob:
John:
Cat:
.float 20.0"""
        check a == a2

    test "command with call instructions":
        const a =
            ppc:
                lfs f1, 0x2C(r31)
                lfs f2, 0x10(r31)
        const a2 = """
lfs f1, 44(r31)
lfs f2, 16(r31)"""
        check a == a2

    test "command with call nim interop":
        proc calculateOffset(address: int64): int64 =
            address + 20
        type Stuff = enum
            Apple = 0,
            Orange = 1
        const regName = "r29"
        const offset = 0x820
        const a =
            ppc:
                lfs f0, 0x10(%regName)
                lfs f1, %*Stuff.Orange.int64(r20)
                lfs f1, %*(calculateOffset(Stuff.Orange.int64 + 20) + offset)(%regName)
                Bob:
                    lfs f2, %*offset(%regName)
                    lfs f3, %*offset(r20)
                    lfs f4, 0x14(%regName)
        const a2 = """
lfs f0, 16(r29)
lfs f1, 1(r20)
lfs f1, 2121(r29)
Bob:
lfs f2, 2080(r29)
lfs f3, 2080(r20)
lfs f4, 20(r29)"""
        check a == a2

    test "command nim interop":
        const regName = "r29"
        const offset = 0x820
        const a =
            ppc:
                li %regName, %offset
        const a2 = "li r29, 2080"
        check a == a2

    test "function nim interop":
        proc calculateOffset(address: int64): string =
            "li r4, " & $address
        const a =
            ppc:
                %calculateOffset(69)
        const a2 = "li r4, 69"
        check a == a2

    test "function with block stmt nim interop":
        template insertAsm(address: int64, body: untyped): string =
            ppc: body
        const a =
            ppc:
                li r3, 20
                %insertAsm(0x80158015):
                    li r4, 10
                    nop
        const a2 = """
li r3, 20
li r4, 10
nop"""
        check a == a2

    test "special @ symbols":
        const reg = "r12"
        const address = 0x80151234
        const a =
            ppc:
                lis %reg, 0x80151234 @h
                ori %reg, %reg, 0x80151234 @l
                lis %reg, %address @h
                # TODO test no space between the @h and @l
        const a2 = """
lis r12, 2148864564 @h
ori r12, r12, 2148864564 @l
lis r12, 2148864564 @h"""
        check a == a2

    test "command & function nim interop":
        proc calculateOffset(address: int64): string =
            "li r4, " & $address
        type Stuff = enum
            Apple = 0,
            Orange = 1
        const a =
            ppc:
                %calculateOffset(Stuff.Apple.int64)
                %(Stuff.Orange.int64.calculateOffset)
                li r3, %(Stuff.Apple.int64)
        const a2 = """
li r4, 0
li r4, 1
li r3, 0"""
        check a == a2

    test "branches & nim interop":
        proc calculateOffset(address: int64): string =
            "li r4, " & $address
        template insertAsm(address: int64, body: untyped): string =
            ppc:
                body
        type Stuff = enum
            Apple = 0,
            Orange = 1
        const no = 10
        const address = 0x80158012
        const a =
            ppc:
                nop
                li r3, 0
                b CheckState
                CheckState:
                    %insertAsm(0x80158015):
                        %calculateOffset(20)
                    cmpwi r2, %($Stuff.Apple.int64)
                    MoreChecks:
                        %insertAsm(address):
                            cmpwi r4, %no
                            ble+ Exit
                        %calculateOffset(0)
                Exit:
                    nop
        const a2 = """
nop
li r3, 0
b CheckState
CheckState:
li r4, 20
cmpwi r2, 0
MoreChecks:
cmpwi r4, 10
ble+ Exit
li r4, 0
Exit:
nop"""
        check a == a2

import unittest
import ../src/geckon

suite "gecko code scripts":

    test "new gecko code script":
        const s =
            createCode "Test code":
                authors: ["ronnie", "bob"]
                description: "my test code"
                code:
                    li r4, 20
                    Test:
                        lfs f1, 0x6(r31)
        const c = """
li r4, 20
Test:
lfs f1, 0x00000006(r31)"""
        check:
            s.name == "Test code"
            s.authors == ["ronnie", "bob"]
            s.description == "my test code"
            s.code == c

    test "code script static name":
        const name = "Test code"
        const s =
            createCode name:
                authors: ["ronnie", "bob"]
                description: "my test code"
                code:
                    li r4, 20
                    Test:
                        lfs f1, 0x6(r31)
        const c = """
li r4, 20
Test:
lfs f1, 0x00000006(r31)"""
        check:
            s.name == "Test code"
            s.authors == ["ronnie", "bob"]
            s.description == "my test code"
            s.code == c
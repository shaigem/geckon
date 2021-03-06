# geckon

A simple build framework for creating ASM Gecko codes in Nim.

Note: `geckon` is still in development. The APIs for creating codes are subject to change.

## Usage

Please see the [melee](melee) folder for examples of real Gecko codes written for [Super Smash Bros. Melee](https://en.wikipedia.org/wiki/Super_Smash_Bros._Melee).

### Simple Example

```nim
import geckon

defineCodes:
    createCode "My New Code Name":
        authors "Bob"
        description "Does cool things"

        patchWrite32Bits "802724A4":
            nop # replaces the single code line at 802724A4 with 'nop'
        
        patchInsertAsm "802724A8":
            # branch to the address 80380580
            lis r12, {0x80380580} @h
            ori r12, r12, {0x80380580} @l
            mtctr r12
            bctrl
            # or you can call branchLink() from geckon/common.nim:
            %branchLink($0x80380580)

build:
    # can specify as many codes as you want
    addCodes Codes
    # by default, all generated .asm and .o files are kept in a folder called 'generated'
    # can specify `keepObjFiles = false` to remove all .o files and keep only .asm files
    output:
        writeCodesToFile "./codes.txt"
```
Running the script above produces the following gecko code in a file called `codes.txt`:
```
$My New Code Name [Bob]
*Does cool things
042724A4 60000000
C22724A8 00000005
3D808038 618C0580
7D8903A6 4E800421
3D808038 618C0580
7D8903A6 4E800421
60000000 00000000
```

It also generates the following ASM code for reference:
```asm
# 802724A4
nop
```
```asm
# 802724A8
lis r12, 2151155072 @h
ori r12, r12, 2151155072 @l
mtctr r12
bctrl
lis r12, 2151155072 @h
ori r12, r12, 2151155072 @l
mtctr r12
bctrl
```

## License

[MIT](https://choosealicense.com/licenses/mit/)

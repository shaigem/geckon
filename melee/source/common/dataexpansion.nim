const
    OldHitboxCount* = 4
    NewHitboxCount* = 8
    AddedHitCount = NewHitboxCount - OldHitboxCount
    FtHitSize* = 312
    ItHitSize* = 316

type
    GameHeaderInfo* = object
        name*: string
        fighterDataSize*: int
        itemDataSize*: int
    HitFlag* {.size: sizeof(uint32).} = enum
        hfAffectOnlyThrow,
        hfNoStale,
        hfNoMeteorCancel,
        hfFlinchless,
        hfUnk,
        hfAngleFlipCurrent,
        hfAngleFlipOpposite,
        hfSetWeight
    HitFlags = set[HitFlag]

    HitAdvFlag* {.size: sizeof(uint32).} = enum
        hafUnk1,
        hafUnk2,
        hafUnk3,
        hafUnk4,
        hafUnk5,
        hafUnk6,
        hafUnk7,
        hafStretch
    HitAdvFlags = set[HitAdvFlag]

    FighterFlag* {.size: sizeof(uint32).} = enum
        ffHitByFlinchless,
        ffSetWeight,
        ffDisableMeteorCancel,
        ffForceHitlagOnThrown,
        ffAttackVecPull # 367 autolink
    FighterFlags = set[FighterFlag]

    SpecialHitAdvanced* = object
        offsetX2*: float32
        offsetY2*: float32
        offsetZ2*: float32
        hitAdvFlags*: HitAdvFlags
        shaPadding*: array[7, float32] # spots for a few more variables

    SpecialHit* = object
        hitlagMultiplier*: float32
        sdiMultiplier*: float32
        shieldStunMultiplier*: float32
        hitstunModifier*: float32
        hitFlags*: HitFlags
        advanced*: SpecialHitAdvanced

    ExtData* = object
        specialHits*: array[NewHitboxCount, SpecialHit]

    ExtItemData* = object
        sharedData*: ExtData
        newHits*: array[AddedHitCount * ItHitSize, byte]
        hitlagMultiplier*: float32

    ExtFighterData* = object
        sharedData*: ExtData
        specialThrowHit*: SpecialHit
        newHits*: array[AddedHitCount * FtHitSize, byte]
        sdiMultiplier*: float32
        hitstunModifier*: float32
        shieldstunMultiplier*: float32
        fighterFlags*: FighterFlags

template extFtDataOff*(gameInfo: GameHeaderInfo; member: untyped): int = gameInfo.fighterDataSize + offsetOf(ExtFighterData, member)
template extItDataOff*(gameInfo: GameHeaderInfo; member: untyped): int = gameInfo.itemDataSize + offsetOf(ExtItemData, member)
template extHitOff*(member: untyped): int = offsetOf(SpecialHit, member)
template extHitAdvOff*(member: untyped): int = extHitOff(advanced) + offsetOf(SpecialHitAdvanced, member)

proc initGameHeaderInfo(name: string; fighterDataSize, itemDataSize: int): GameHeaderInfo =
    result.name = name
    result.fighterDataSize = fighterDataSize
    result.itemDataSize = itemDataSize

proc flag*(f: HitFlag|FighterFlag|HitAdvFlag): int = 1 shl f.ord

const
    VanillaHeaderInfo* = initGameHeaderInfo("Vanilla", fighterDataSize = 0x23EC, itemDataSize = 0xFCC)
    # as of commit #f779005 Nov-29-2021 @ 1:28 AM EST
    MexHeaderInfo* = initGameHeaderInfo("m-ex", fighterDataSize = 
        VanillaHeaderInfo.fighterDataSize + 52, 
            itemDataSize = VanillaHeaderInfo.itemDataSize + 4)

echo sizeof(SpecialHitAdvanced.shaPadding)
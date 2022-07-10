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
        hfDisableHitlag,
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
        hafNoHitstunCancel
    HitAdvFlags = set[HitAdvFlag]

    HitStdFlag* {.size: sizeof(uint32).} = enum
        hsfUnk1,
        hsfUnk2,
        hsfUnk3,
        hsfUnk4,
        hsfUnk5,
        hsfUnk6,
        hsfUnk7,
        hsfStretch
    HitStdFlags = set[HitStdFlag]

    HitVecTargetPosFlag* {.size: sizeof(uint8).} = enum
        hvtfIsSet
        hvtfUnk2
        hvtfLerpAtkMom
        hvtfLerpSpeedCap
        hvtfCalcVecPull
        hvtfCalcVecTargetPos
        hvtfOverrideSpeed
        hvtfAfterHitlag
    HitVecTargetPosFlags = set[HitVecTargetPosFlag]

    FighterFlag* {.size: sizeof(uint8).} = enum
        ffHitByFlinchless,
        ffSetWeight,
        ffDisableMeteorCancel,
        ffForceHitlagOnThrown,
        ffAttackVecTargetPos
        ffDisableHitlag
        ffNoHitstunCancel
    FighterFlags = set[FighterFlag]

    SpecialHitAdvanced* = object
        padding*: array[3, float32] # spots for a few more variables
        hitAdvFlags*: HitAdvFlags

    SpecialHitNormal* = object
        hitlagMultiplier*: float32
        sdiMultiplier*: float32
        shieldStunMultiplier*: float32
        hitstunModifier*: float32
        hitFlags*: HitFlags

    SpecialHitAttackCapsule* = object
        offsetX2*: float32
        offsetY2*: float32
        offsetZ2*: float32

    SpecialHitSetVecTargetPos* = object
        targetPosNode*: float32
        targetPosFrame*: float32
        targetPosOffsetX*: float32
        targetPosOffsetY*: float32
        targetPosOffsetZ*: float32
        targetPosFlags*: HitVecTargetPosFlags
        targetPosPadding: int8

    SpecialHit* = object
        hitNormal*: SpecialHitNormal
        hitCapsule*: SpecialHitAttackCapsule
        hitAdvanced*: SpecialHitAdvanced
        hitStdFlags*: HitStdFlags
        hitTargetPos*: SpecialHitSetVecTargetPos
        padding*: array[2, float32] # spots for a few more variables

    # variables should be added at the end of each ExtItem/FighterData struct
    # should not delete or insert between

    ExtItemData* = object
        specialHits*: array[NewHitboxCount, SpecialHit]
        newHits*: array[AddedHitCount * ItHitSize, byte]
        hitlagMultiplier*: float32

    ExtFighterData* = object
        specialHits*: array[NewHitboxCount, SpecialHit]
        specialThrowHit*: SpecialHit
        newHits*: array[AddedHitCount * FtHitSize, byte]
        sdiMultiplier*: float32
        hitstunModifier*: float32
        shieldstunMultiplier*: float32
        fighterFlags*: FighterFlags
        fighterFlags2*: FighterFlags
        padding2*: int16
        # autolink related
        vecTargetPosFrame*: float32
        vecTargetPosX*: float32
        vecTargetPosY*: float32
        vecTargetAttackerSpeedX*: float32        
        vecTargetAttackerSpeedY*: float32
        vecTargetPosFlags*: HitVecTargetPosFlags
        padding3*: array[3, int8]

template extFtDataOff*(gameInfo: GameHeaderInfo; member: untyped): int = gameInfo.fighterDataSize + offsetOf(ExtFighterData, member)
template extItDataOff*(gameInfo: GameHeaderInfo; member: untyped): int = gameInfo.itemDataSize + offsetOf(ExtItemData, member)
template extHitOff*(member: untyped): int = offsetOf(SpecialHit, member)
template extHitNormOff*(member: untyped): int = extHitOff(hitNormal) + offsetOf(SpecialHitNormal, member)
template extHitAtkCapOff*(member: untyped): int = extHitOff(hitCapsule) + offsetOf(SpecialHitAttackCapsule, member)
template extHitAdvOff*(member: untyped): int = extHitOff(hitAdvanced) + offsetOf(SpecialHitAdvanced, member)
template extHitTargetPosOff*(member: untyped): int = extHitOff(hitTargetPos) + offsetOf(SpecialHitSetVecTargetPos, member)

proc initGameHeaderInfo(name: string; fighterDataSize, itemDataSize: int): GameHeaderInfo =
    result.name = name
    result.fighterDataSize = fighterDataSize
    result.itemDataSize = itemDataSize

proc flag*(f: HitFlag|FighterFlag|HitStdFlag|HitAdvFlag): int = 1 shl f.ord

const
    VanillaHeaderInfo* = initGameHeaderInfo("Vanilla", fighterDataSize = 0x23EC, itemDataSize = 0xFCC)
    # as of commit #f779005 Nov-29-2021 @ 1:28 AM EST
    MexHeaderInfo* = initGameHeaderInfo("m-ex", fighterDataSize = 
        VanillaHeaderInfo.fighterDataSize + 52, 
            itemDataSize = VanillaHeaderInfo.itemDataSize + 4)

echo (sizeof(SpecialHitAdvanced) / sizeof(uint32)).uint32
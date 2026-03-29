struct Block {
    let id: UInt8
    let data: UInt8

    init(id: UInt8, data: UInt8) {
        self.id = id
        self.data = data
    }

    init(id: UInt8) {
        self.id = id
        self.data = 0
    }
}

protocol BlockLike {
    var id: UInt8 {
        get
    }

    func asBlock() -> Block
}

extension Block: BlockLike {
    func asBlock() -> Block {
        self
    }
}

enum Direction: UInt8 {
    case north = 0
    case east = 1
    case south = 2
    case west = 3
}

enum WoodType: UInt8 {
    case oak = 0
    case spruce = 1
    case birch = 2
}

enum WoolColor: UInt8 {
    case white = 0
    case orange = 1
    case magenta = 2
    case lightBlue = 3
    case yellow = 4
    case lime = 5
    case pink = 6
    case gray = 7
    case lightGray = 8
    case cyan = 9
    case purple = 10
    case blue = 11
    case brown = 12
    case green = 13
    case red = 14
    case black = 15
}

enum SlabType: UInt8 {
    case stone = 0
    case sandstone = 1
    case wood = 2
    case cobblestone = 3
}

enum TallGrassType: UInt8 {
    case deadBush = 0
    case tallGrass = 1
    case fern = 2
}

enum TorchAttachment: UInt8 {
    case westWall = 1
    case eastWall = 2
    case northWall = 3
    case southWall = 4
    case floor = 5
}

enum RedstoneTorchAttachment: UInt8 {
    case westWall = 1
    case eastWall = 2
    case southWall = 3
    case northWall = 4
    case floor = 5
}

enum WallFacing: UInt8 {
    case south = 2
    case north = 3
    case east = 4
    case west = 5
}

enum LeverMount: UInt8 {
    case westWall = 1
    case eastWall = 2
    case southWall = 3
    case northWall = 4
    case floorEastWest = 5
    case floorNorthSouth = 6
}

enum ButtonMount: UInt8 {
    case westWall = 1
    case eastWall = 2
    case southWall = 3
    case northWall = 4
    case ceiling = 5
}

enum RailShape: UInt8 {
    case flatNorthSouth = 0
    case flatEastWest = 1
    case ascendingEast = 2
    case ascendingWest = 3
    case ascendingSouth = 4
    case ascendingNorth = 5
    case curveNorthEast = 6
    case curveSouthEast = 7
    case curveSouthWest = 8
    case curveNorthWest = 9
}

enum PistonFacing: UInt8 {
    case up = 0
    case down = 1
    case south = 2
    case north = 3
    case west = 4
    case east = 5
}

struct StairsBuilder: BlockLike {
    let id: UInt8
    let direction: Direction
    let upsideDown: Bool

    init(id: UInt8, direction: Direction = .north, upsideDown: Bool = false) {
        self.id = id
        self.direction = direction
        self.upsideDown = upsideDown
    }

    init(id: UInt8, data: UInt8) {
        self.id = id
        self.direction = Direction(rawValue: data & 0x3) ?? .north
        self.upsideDown = data & 0x4 != 0
    }

    func facing(_ direction: Direction) -> StairsBuilder {
        StairsBuilder(id: id, direction: direction, upsideDown: upsideDown)
    }

    func upsideDown(_ upsideDown: Bool) -> StairsBuilder {
        StairsBuilder(id: id, direction: direction, upsideDown: upsideDown)
    }

    func asBlock() -> Block {
        var data = direction.rawValue
        if upsideDown { data |= 0x4 }
        return Block(id: id, data: data)
    }
}

struct FluidBuilder: BlockLike {
    let id: UInt8
    let level: UInt8
    let falling: Bool

    init(id: UInt8, level: UInt8 = 0, falling: Bool = false) {
        self.id = id
        self.level = min(level, 7)
        self.falling = falling
    }

    init(id: UInt8, data: UInt8) {
        self.id = id
        self.level = data & 0x7
        self.falling = data & 0x8 != 0
    }

    func level(_ level: UInt8) -> FluidBuilder {
        FluidBuilder(id: id, level: level, falling: falling)
    }

    func falling(_ falling: Bool) -> FluidBuilder {
        FluidBuilder(id: id, level: level, falling: falling)
    }

    func asBlock() -> Block {
        var data = level & 0x7
        if falling { data |= 0x8 }
        return Block(id: id, data: data)
    }
}

struct SaplingBuilder: BlockLike {
    let id: UInt8 = 6
    let treeType: WoodType
    let readyToGrow: Bool

    init(treeType: WoodType = .oak, readyToGrow: Bool = false) {
        self.treeType = treeType
        self.readyToGrow = readyToGrow
    }

    init(data: UInt8) {
        self.treeType = WoodType(rawValue: data & 0x3) ?? .oak
        self.readyToGrow = data & 0x8 != 0
    }

    func treeType(_ treeType: WoodType) -> SaplingBuilder {
        SaplingBuilder(treeType: treeType, readyToGrow: readyToGrow)
    }

    func readyToGrow(_ readyToGrow: Bool) -> SaplingBuilder {
        SaplingBuilder(treeType: treeType, readyToGrow: readyToGrow)
    }

    func asBlock() -> Block {
        var data = treeType.rawValue

        if readyToGrow {
            data |= 0x8
        }

        return Block(id: id, data: data)
    }
}

struct LogBuilder: BlockLike {
    let id: UInt8 = 17
    let treeType: WoodType

    init(treeType: WoodType = .oak) {
        self.treeType = treeType
    }

    init(data: UInt8) {
        self.treeType = WoodType(rawValue: data & 0x3) ?? .oak
    }

    func treeType(_ treeType: WoodType) -> LogBuilder {
        LogBuilder(treeType: treeType)
    }

    func asBlock() -> Block {
        Block(id: id, data: treeType.rawValue)
    }
}

struct LeavesBuilder: BlockLike {
    let id: UInt8 = 18
    let treeType: WoodType
    let decaying: Bool

    init(treeType: WoodType = .oak, decaying: Bool = false) {
        self.treeType = treeType
        self.decaying = decaying
    }

    init(data: UInt8) {
        self.treeType = WoodType(rawValue: data & 0x3) ?? .oak
        self.decaying = data & 0x8 != 0
    }

    func treeType(_ treeType: WoodType) -> LeavesBuilder {
        LeavesBuilder(treeType: treeType, decaying: decaying)
    }

    func decaying(_ decaying: Bool) -> LeavesBuilder {
        LeavesBuilder(treeType: treeType, decaying: decaying)
    }

    func asBlock() -> Block {
        var data = treeType.rawValue

        if decaying {
            data |= 0x8
        }

        return Block(id: id, data: data)
    }
}

struct TallGrassBuilder: BlockLike {
    let id: UInt8 = 31
    let variant: TallGrassType

    init(variant: TallGrassType = .tallGrass) {
        self.variant = variant
    }

    init(data: UInt8) {
        self.variant = TallGrassType(rawValue: data) ?? .tallGrass
    }

    func variant(_ variant: TallGrassType) -> TallGrassBuilder {
        TallGrassBuilder(variant: variant)
    }

    func asBlock() -> Block {
        Block(id: id, data: variant.rawValue)
    }
}

struct WoolBuilder: BlockLike {
    let id: UInt8 = 35
    let color: WoolColor

    init(color: WoolColor = .white) {
        self.color = color
    }

    init(data: UInt8) {
        self.color = WoolColor(rawValue: ~data & 0xF) ?? .white
    }

    func color(_ color: WoolColor) -> WoolBuilder {
        WoolBuilder(color: color)
    }

    func asBlock() -> Block {
        Block(id: id, data: ~color.rawValue & 0xF)
    }
}

struct SlabBuilder: BlockLike {
    let id: UInt8
    let material: SlabType

    init(id: UInt8, material: SlabType = .stone) {
        self.id = id
        self.material = material
    }

    init(id: UInt8, data: UInt8) {
        self.id = id
        self.material = SlabType(rawValue: data) ?? .stone
    }

    func material(_ material: SlabType) -> SlabBuilder {
        SlabBuilder(id: id, material: material)
    }

    func asBlock() -> Block {
        Block(id: id, data: material.rawValue)
    }
}

struct TorchBuilder: BlockLike {
    let id: UInt8
    let attachment: TorchAttachment

    init(id: UInt8, attachment: TorchAttachment = .floor) {
        self.id = id
        self.attachment = attachment
    }

    init(id: UInt8, data: UInt8) {
        self.id = id
        self.attachment = TorchAttachment(rawValue: data) ?? .floor
    }

    func attachment(_ attachment: TorchAttachment) -> TorchBuilder {
        TorchBuilder(id: id, attachment: attachment)
    }

    func asBlock() -> Block {
        Block(id: id, data: attachment.rawValue)
    }
}

struct RedstoneTorchBuilder: BlockLike {
    let id: UInt8
    let attachment: RedstoneTorchAttachment

    init(id: UInt8, attachment: RedstoneTorchAttachment = .floor) {
        self.id = id
        self.attachment = attachment
    }

    init(id: UInt8, data: UInt8) {
        self.id = id
        self.attachment = RedstoneTorchAttachment(rawValue: data) ?? .floor
    }

    func attachment(_ attachment: RedstoneTorchAttachment) -> RedstoneTorchBuilder {
        RedstoneTorchBuilder(id: id, attachment: attachment)
    }

    func asBlock() -> Block {
        Block(id: id, data: attachment.rawValue)
    }
}

struct WallFacingBuilder: BlockLike {
    let id: UInt8
    let facing: WallFacing

    init(id: UInt8, facing: WallFacing = .north) {
        self.id = id
        self.facing = facing
    }

    init(id: UInt8, data: UInt8) {
        self.id = id
        self.facing = WallFacing(rawValue: data) ?? .north
    }

    func facing(_ facing: WallFacing) -> WallFacingBuilder {
        WallFacingBuilder(id: id, facing: facing)
    }

    func asBlock() -> Block {
        Block(id: id, data: facing.rawValue)
    }
}

struct BedBuilder: BlockLike {
    let id: UInt8 = 26
    let direction: Direction
    let occupied: Bool
    let head: Bool

    init(direction: Direction = .north, occupied: Bool = false, head: Bool = false) {
        self.direction = direction
        self.occupied = occupied
        self.head = head
    }

    init(data: UInt8) {
        self.direction = Direction(rawValue: data & 0x3) ?? .north
        self.occupied = data & 0x4 != 0
        self.head = data & 0x8 != 0
    }

    func facing(_ direction: Direction) -> BedBuilder {
        BedBuilder(direction: direction, occupied: occupied, head: head)
    }

    func occupied(_ occupied: Bool) -> BedBuilder {
        BedBuilder(direction: direction, occupied: occupied, head: head)
    }

    func head(_ head: Bool) -> BedBuilder {
        BedBuilder(direction: direction, occupied: occupied, head: head)
    }

    func asBlock() -> Block {
        var data = direction.rawValue

        if occupied {
            data |= 0x4
        }

        if head {
            data |= 0x8
        }

        return Block(id: id, data: data)
    }
}

struct PoweredRailBuilder: BlockLike {
    let id: UInt8
    let shape: RailShape
    let powered: Bool

    init(id: UInt8, shape: RailShape = .flatNorthSouth, powered: Bool = false) {
        self.id = id
        self.shape = shape
        self.powered = powered
    }

    init(id: UInt8, data: UInt8) {
        self.id = id
        self.shape = RailShape(rawValue: data & 0x7) ?? .flatNorthSouth
        self.powered = data & 0x8 != 0
    }

    func shape(_ shape: RailShape) -> PoweredRailBuilder {
        PoweredRailBuilder(id: id, shape: shape, powered: powered)
    }

    func powered(_ powered: Bool) -> PoweredRailBuilder {
        PoweredRailBuilder(id: id, shape: shape, powered: powered)
    }

    func asBlock() -> Block {
        var data = shape.rawValue & 0x7

        if powered {
            data |= 0x8
        }

        return Block(id: id, data: data)
    }
}

struct PistonBuilder: BlockLike {
    let id: UInt8
    let facing: PistonFacing
    let extended: Bool

    init(id: UInt8, facing: PistonFacing = .up, extended: Bool = false) {
        self.id = id
        self.facing = facing
        self.extended = extended
    }

    init(id: UInt8, data: UInt8) {
        self.id = id
        self.facing = PistonFacing(rawValue: data & 0x7) ?? .up
        self.extended = data & 0x8 != 0
    }

    func facing(_ facing: PistonFacing) -> PistonBuilder {
        PistonBuilder(id: id, facing: facing, extended: extended)
    }

    func extended(_ extended: Bool) -> PistonBuilder {
        PistonBuilder(id: id, facing: facing, extended: extended)
    }

    func asBlock() -> Block {
        var data = facing.rawValue

        if extended {
            data |= 0x8
        }

        return Block(id: id, data: data)
    }
}

struct PistonHeadBuilder: BlockLike {
    let id: UInt8 = 34
    let facing: PistonFacing
    let sticky: Bool

    init(facing: PistonFacing = .up, sticky: Bool = false) {
        self.facing = facing
        self.sticky = sticky
    }

    init(data: UInt8) {
        self.facing = PistonFacing(rawValue: data & 0x7) ?? .up
        self.sticky = data & 0x8 != 0
    }

    func facing(_ facing: PistonFacing) -> PistonHeadBuilder {
        PistonHeadBuilder(facing: facing, sticky: sticky)
    }

    func sticky(_ sticky: Bool) -> PistonHeadBuilder {
        PistonHeadBuilder(facing: facing, sticky: sticky)
    }

    func asBlock() -> Block {
        var data = facing.rawValue

        if sticky {
            data |= 0x8
        }

        return Block(id: id, data: data)
    }
}

struct DoorBuilder: BlockLike {
    let id: UInt8
    let rotation: UInt8
    let open: Bool
    let upperHalf: Bool

    init(id: UInt8, rotation: UInt8 = 0, open: Bool = false, upperHalf: Bool = false) {
        self.id = id
        self.rotation = rotation & 0x3
        self.open = open
        self.upperHalf = upperHalf
    }

    init(id: UInt8, data: UInt8) {
        self.id = id
        self.rotation = data & 0x3
        self.open = data & 0x4 != 0
        self.upperHalf = data & 0x8 != 0
    }

    func rotation(_ rotation: UInt8) -> DoorBuilder {
        DoorBuilder(id: id, rotation: rotation, open: open, upperHalf: upperHalf)
    }

    func open(_ open: Bool) -> DoorBuilder {
        DoorBuilder(id: id, rotation: rotation, open: open, upperHalf: upperHalf)
    }

    func upperHalf(_ upperHalf: Bool) -> DoorBuilder {
        DoorBuilder(id: id, rotation: rotation, open: open, upperHalf: upperHalf)
    }

    func asBlock() -> Block {
        var data = rotation

        if open {
            data |= 0x4
        }

        if upperHalf {
            data |= 0x8
        }

        return Block(id: id, data: data)
    }
}

struct SignBuilder: BlockLike {
    let id: UInt8 = 63
    let rotation: UInt8

    init(rotation: UInt8 = 0) {
        self.rotation = rotation & 0xF
    }

    init(data: UInt8) {
        self.rotation = data & 0xF
    }

    func rotation(_ rotation: UInt8) -> SignBuilder {
        SignBuilder(rotation: rotation)
    }

    func asBlock() -> Block {
        Block(id: id, data: rotation & 0xF)
    }
}

struct RailBuilder: BlockLike {
    let id: UInt8 = 66
    let shape: RailShape

    init(shape: RailShape = .flatNorthSouth) {
        self.shape = shape
    }

    init(data: UInt8) {
        self.shape = RailShape(rawValue: data) ?? .flatNorthSouth
    }

    func shape(_ shape: RailShape) -> RailBuilder {
        RailBuilder(shape: shape)
    }

    func asBlock() -> Block {
        Block(id: id, data: shape.rawValue)
    }
}

struct LeverBuilder: BlockLike {
    let id: UInt8 = 69
    let mount: LeverMount
    let on: Bool

    init(mount: LeverMount = .floorEastWest, on: Bool = false) {
        self.mount = mount
        self.on = on
    }

    init(data: UInt8) {
        self.mount = LeverMount(rawValue: data & 0x7) ?? .floorEastWest
        self.on = data & 0x8 != 0
    }

    func mount(_ mount: LeverMount) -> LeverBuilder {
        LeverBuilder(mount: mount, on: on)
    }

    func on(_ on: Bool) -> LeverBuilder {
        LeverBuilder(mount: mount, on: on)
    }

    func asBlock() -> Block {
        var data = mount.rawValue

        if on {
            data |= 0x8
        }

        return Block(id: id, data: data)
    }
}

struct ButtonBuilder: BlockLike {
    let id: UInt8 = 77
    let mount: ButtonMount
    let pressed: Bool

    init(mount: ButtonMount = .ceiling, pressed: Bool = false) {
        self.mount = mount
        self.pressed = pressed
    }

    init(data: UInt8) {
        self.mount = ButtonMount(rawValue: data & 0x7) ?? .ceiling
        self.pressed = data & 0x8 != 0
    }

    func mount(_ mount: ButtonMount) -> ButtonBuilder {
        ButtonBuilder(mount: mount, pressed: pressed)
    }

    func pressed(_ pressed: Bool) -> ButtonBuilder {
        ButtonBuilder(mount: mount, pressed: pressed)
    }

    func asBlock() -> Block {
        var data = mount.rawValue

        if pressed {
            data |= 0x8
        }

        return Block(id: id, data: data)
    }
}

struct SnowLayerBuilder: BlockLike {
    let id: UInt8 = 78
    let height: UInt8

    init(height: UInt8 = 0) {
        self.height = min(height, 7)
    }

    init(data: UInt8) {
        self.height = data & 0x7
    }

    func height(_ height: UInt8) -> SnowLayerBuilder {
        SnowLayerBuilder(height: height)
    }

    func asBlock() -> Block {
        Block(id: id, data: height & 0x7)
    }
}

struct TrapdoorBuilder: BlockLike {
    let id: UInt8 = 96
    let direction: Direction
    let open: Bool

    init(direction: Direction = .south, open: Bool = false) {
        self.direction = direction
        self.open = open
    }

    init(data: UInt8) {
        switch data & 0x3 {
        case 0: self.direction = .south
        case 1: self.direction = .north
        case 2: self.direction = .east
        default: self.direction = .west
        }

        self.open = data & 0x4 != 0
    }

    func facing(_ direction: Direction) -> TrapdoorBuilder {
        TrapdoorBuilder(direction: direction, open: open)
    }

    func open(_ open: Bool) -> TrapdoorBuilder {
        TrapdoorBuilder(direction: direction, open: open)
    }

    func asBlock() -> Block {
        var data: UInt8

        switch direction {
        case .south: data = 0
        case .north: data = 1
        case .east: data = 2
        case .west: data = 3
        }

        if open {
            data |= 0x4
        }

        return Block(id: id, data: data)
    }
}

struct PumpkinBuilder: BlockLike {
    let id: UInt8
    let direction: Direction

    init(id: UInt8, direction: Direction = .north) {
        self.id = id
        self.direction = direction
    }

    init(id: UInt8, data: UInt8) {
        self.id = id
        self.direction = Direction(rawValue: data & 0x3) ?? .north
    }

    func facing(_ direction: Direction) -> PumpkinBuilder {
        PumpkinBuilder(id: id, direction: direction)
    }

    func asBlock() -> Block {
        Block(id: id, data: direction.rawValue)
    }
}

struct RepeaterBuilder: BlockLike {
    let id: UInt8
    let direction: Direction
    let delay: UInt8

    init(id: UInt8, direction: Direction = .north, delay: UInt8 = 0) {
        self.id = id
        self.direction = direction
        self.delay = min(delay, 3)
    }

    init(id: UInt8, data: UInt8) {
        self.id = id

        switch data & 0x3 {
        case 0: self.direction = .north
        case 1: self.direction = .west
        case 2: self.direction = .south
        default: self.direction = .east
        }

        self.delay = (data >> 2) & 0x3
    }

    func facing(_ direction: Direction) -> RepeaterBuilder {
        RepeaterBuilder(id: id, direction: direction, delay: delay)
    }

    func delay(_ delay: UInt8) -> RepeaterBuilder {
        RepeaterBuilder(id: id, direction: direction, delay: delay)
    }

    var delayTicks: Int {
        (Int(delay) + 1) * 2
    }

    func asBlock() -> Block {
        var data: UInt8

        switch direction {
        case .north: data = 0
        case .west: data = 1
        case .south: data = 2
        case .east: data = 3
        }

        data |= (delay & 0x3) << 2
        return Block(id: id, data: data)
    }
}

extension Block {
    static let air = Block(id: 0)
    static let stone = Block(id: 1)
    static let grass = Block(id: 2)
    static let dirt = Block(id: 3)
    static let cobblestone = Block(id: 4)
    static let planks = Block(id: 5)
    static let sapling = SaplingBuilder()
    static let bedrock = Block(id: 7)
    static let flowingWater = FluidBuilder(id: 8)
    static let water = FluidBuilder(id: 9)
    static let flowingLava = FluidBuilder(id: 10)
    static let lava = FluidBuilder(id: 11)
    static let sand = Block(id: 12)
    static let gravel = Block(id: 13)
    static let goldOre = Block(id: 14)
    static let ironOre = Block(id: 15)
    static let coalOre = Block(id: 16)
    static let log = LogBuilder()
    static let leaves = LeavesBuilder()
    static let sponge = Block(id: 19)
    static let glass = Block(id: 20)
    static let lapisLazuliOre = Block(id: 21)
    static let lapisLazuli = Block(id: 22)
    static let dispenser = WallFacingBuilder(id: 23)
    static let sandstone = Block(id: 24)
    static let noteBlock = Block(id: 25)
    static let bed = BedBuilder()
    static let poweredRail = PoweredRailBuilder(id: 27)
    static let detectorRail = PoweredRailBuilder(id: 28)
    static let stickyPiston = PistonBuilder(id: 29)
    static let cobweb = Block(id: 30)
    static let tallGrass = TallGrassBuilder()
    static let deadBush = Block(id: 32)
    static let piston = PistonBuilder(id: 33)
    static let pistonHead = PistonHeadBuilder()
    static let wool = WoolBuilder()
    static let movingBlock = Block(id: 36)
    static let dandelion = Block(id: 37)
    static let rose = Block(id: 38)
    static let brownMushroom = Block(id: 39)
    static let redMushroom = Block(id: 40)
    static let gold = Block(id: 41)
    static let iron = Block(id: 42)
    static let doubleSlab = SlabBuilder(id: 43)
    static let slab = SlabBuilder(id: 44)
    static let bricks = Block(id: 45)
    static let tnt = Block(id: 46)
    static let bookshelf = Block(id: 47)
    static let mossyCobblestone = Block(id: 48)
    static let obsidian = Block(id: 49)
    static let torch = TorchBuilder(id: 50)
    static let fire = Block(id: 51)
    static let mobSpawner = Block(id: 52)
    static let woodenStairs = StairsBuilder(id: 53)
    static let chest = Block(id: 54)
    static let redstoneDust = Block(id: 55)
    static let diamondOre = Block(id: 56)
    static let diamond = Block(id: 57)
    static let craftingTable = Block(id: 58)
    static let wheat = Block(id: 59)
    static let farmland = Block(id: 60)
    static let furnace = WallFacingBuilder(id: 61)
    static let litFurnace = WallFacingBuilder(id: 62)
    static let sign = SignBuilder()
    static let woodenDoor = DoorBuilder(id: 64)
    static let ladder = WallFacingBuilder(id: 65)
    static let rail = RailBuilder()
    static let cobblestoneStairs = StairsBuilder(id: 67)
    static let wallSign = WallFacingBuilder(id: 68)
    static let lever = LeverBuilder()
    static let stonePressurePlate = Block(id: 70)
    static let ironDoor = DoorBuilder(id: 71)
    static let woodenPressurePlate = Block(id: 72)
    static let redstoneOre = Block(id: 73)
    static let litRedstoneOre = Block(id: 74)
    static let redstoneTorch = RedstoneTorchBuilder(id: 75)
    static let litRedstoneTorch = RedstoneTorchBuilder(id: 76)
    static let stoneButton = ButtonBuilder()
    static let snow = SnowLayerBuilder()
    static let ice = Block(id: 79)
    static let snowBlock = Block(id: 80)
    static let cactus = Block(id: 81)
    static let clay = Block(id: 82)
    static let sugarCane = Block(id: 83)
    static let jukebox = Block(id: 84)
    static let fence = Block(id: 85)
    static let pumpkin = PumpkinBuilder(id: 86)
    static let netherrack = Block(id: 87)
    static let soulSand = Block(id: 88)
    static let glowstone = Block(id: 89)
    static let netherPortal = Block(id: 90)
    static let jackOLantern = PumpkinBuilder(id: 91)
    static let cake = Block(id: 92)
    static let redstoneRepeater = RepeaterBuilder(id: 93)
    static let litRedstoneRepeater = RepeaterBuilder(id: 94)
    static let trapdoor = TrapdoorBuilder()
}

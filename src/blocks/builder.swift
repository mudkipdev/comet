enum Direction: UInt8, CaseIterable {
    case north = 0
    case east = 1
    case south = 2
    case west = 3
}

enum WoodType: UInt8, CaseIterable {
    case oak = 0
    case spruce = 1
    case birch = 2
}

enum WoolColor: UInt8, CaseIterable {
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

enum SlabType: UInt8, CaseIterable {
    case stone = 0
    case sandstone = 1
    case wood = 2
    case cobblestone = 3
}

enum TallGrassType: UInt8, CaseIterable {
    case deadBush = 0
    case tallGrass = 1
    case fern = 2
}

enum TorchAttachment: UInt8, CaseIterable {
    case westWall = 1
    case eastWall = 2
    case northWall = 3
    case southWall = 4
    case floor = 5
}

enum WallFacing: UInt8, CaseIterable {
    case north = 2
    case south = 3
    case west = 4
    case east = 5
}

enum LeverMount: UInt8, CaseIterable {
    case westWall = 1
    case eastWall = 2
    case northWall = 3
    case southWall = 4
    case floorEastWest = 5
    case floorNorthSouth = 6
}

enum ButtonMount: UInt8, CaseIterable {
    case westWall = 1
    case eastWall = 2
    case northWall = 3
    case southWall = 4
}

enum RailShape: UInt8, CaseIterable {
    case flatNorthSouth = 0
    case flatEastWest = 1
    case ascendingEast = 2
    case ascendingWest = 3
    case ascendingNorth = 4
    case ascendingSouth = 5
    case curveNorthEast = 6
    case curveSouthEast = 7
    case curveSouthWest = 8
    case curveNorthWest = 9
}

enum PistonFacing: UInt8, CaseIterable {
    case down = 0
    case up = 1
    case north = 2
    case south = 3
    case west = 4
    case east = 5
}

enum StairsDirection: UInt8, CaseIterable {
    case east = 0
    case west = 1
    case south = 2
    case north = 3
}

struct StairsBuilder: BlockLike {
    let id: UInt8
    let direction: StairsDirection

    init(id: UInt8, direction: StairsDirection = .east) {
        self.id = id
        self.direction = direction
    }

    init(id: UInt8, data: UInt8) {
        self.id = id
        self.direction = StairsDirection(rawValue: data & 0x3) ?? .east
    }

    func facing(_ direction: StairsDirection) -> StairsBuilder {
        StairsBuilder(id: id, direction: direction)
    }

    func asBlock() -> Block {
        Block(id: id, data: direction.rawValue)
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
    let type: WoodType
    let readyToGrow: Bool

    init(type: WoodType = .oak, readyToGrow: Bool = false) {
        self.type = type
        self.readyToGrow = readyToGrow
    }

    init(data: UInt8) {
        self.type = WoodType(rawValue: data & 0x3) ?? .oak
        self.readyToGrow = data & 0x8 != 0
    }

    func type(_ type: WoodType) -> SaplingBuilder {
        SaplingBuilder(type: type, readyToGrow: readyToGrow)
    }

    func readyToGrow(_ readyToGrow: Bool) -> SaplingBuilder {
        SaplingBuilder(type: type, readyToGrow: readyToGrow)
    }

    func asBlock() -> Block {
        var data = type.rawValue

        if readyToGrow {
            data |= 0x8
        }

        return Block(id: id, data: data)
    }
}

struct LogBuilder: BlockLike {
    let id: UInt8 = 17
    let type: WoodType

    init(type: WoodType = .oak) {
        self.type = type
    }

    init(data: UInt8) {
        self.type = WoodType(rawValue: data & 0x3) ?? .oak
    }

    func type(_ type: WoodType) -> LogBuilder {
        LogBuilder(type: type)
    }

    func asBlock() -> Block {
        Block(id: id, data: type.rawValue)
    }
}

struct LeavesBuilder: BlockLike {
    let id: UInt8 = 18
    let type: WoodType
    let decaying: Bool

    init(type: WoodType = .oak, decaying: Bool = false) {
        self.type = type
        self.decaying = decaying
    }

    init(data: UInt8) {
        self.type = WoodType(rawValue: data & 0x3) ?? .oak
        self.decaying = data & 0x8 != 0
    }

    func type(_ type: WoodType) -> LeavesBuilder {
        LeavesBuilder(type: type, decaying: decaying)
    }

    func decaying(_ decaying: Bool) -> LeavesBuilder {
        LeavesBuilder(type: type, decaying: decaying)
    }

    func asBlock() -> Block {
        var data = type.rawValue

        if decaying {
            data |= 0x8
        }

        return Block(id: id, data: data)
    }
}

struct TallGrassBuilder: BlockLike {
    let id: UInt8 = 31
    let type: TallGrassType

    init(type: TallGrassType = .tallGrass) {
        self.type = type
    }

    init(data: UInt8) {
        self.type = TallGrassType(rawValue: data) ?? .tallGrass
    }

    func type(_ type: TallGrassType) -> TallGrassBuilder {
        TallGrassBuilder(type: type)
    }

    func asBlock() -> Block {
        Block(id: id, data: type.rawValue)
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
    let type: SlabType

    init(id: UInt8, type: SlabType = .stone) {
        self.id = id
        self.type = type
    }

    init(id: UInt8, data: UInt8) {
        self.id = id
        self.type = SlabType(rawValue: data) ?? .stone
    }

    func type(_ type: SlabType) -> SlabBuilder {
        SlabBuilder(id: id, type: type)
    }

    func asBlock() -> Block {
        Block(id: id, data: type.rawValue)
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
    let attachment: TorchAttachment

    init(id: UInt8, attachment: TorchAttachment = .floor) {
        self.id = id
        self.attachment = attachment
    }

    init(id: UInt8, data: UInt8) {
        self.id = id
        self.attachment = TorchAttachment(rawValue: data) ?? .floor
    }

    func attachment(_ attachment: TorchAttachment) -> RedstoneTorchBuilder {
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

    init(direction: Direction = .south, occupied: Bool = false, head: Bool = false) {
        self.direction = direction
        self.occupied = occupied
        self.head = head
    }

    init(data: UInt8) {
        switch data & 0x3 {
        case 0: self.direction = .south
        case 1: self.direction = .west
        case 2: self.direction = .north
        default: self.direction = .east
        }
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
        var data: UInt8
        switch direction {
        case .south: data = 0
        case .west: data = 1
        case .north: data = 2
        case .east: data = 3
        }

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

    init(mount: ButtonMount = .westWall, pressed: Bool = false) {
        self.mount = mount
        self.pressed = pressed
    }

    init(data: UInt8) {
        self.mount = ButtonMount(rawValue: data & 0x7) ?? .westWall
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

    init(id: UInt8, direction: Direction = .south) {
        self.id = id
        self.direction = direction
    }

    init(id: UInt8, data: UInt8) {
        self.id = id
        switch data & 0x3 {
        case 0: self.direction = .south
        case 1: self.direction = .west
        case 2: self.direction = .north
        default: self.direction = .east
        }
    }

    func facing(_ direction: Direction) -> PumpkinBuilder {
        PumpkinBuilder(id: id, direction: direction)
    }

    func asBlock() -> Block {
        var data: UInt8
        switch direction {
        case .south: data = 0
        case .west: data = 1
        case .north: data = 2
        case .east: data = 3
        }
        return Block(id: id, data: data)
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
        case 1: self.direction = .east
        case 2: self.direction = .south
        default: self.direction = .west
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
        case .east: data = 1
        case .south: data = 2
        case .west: data = 3
        }

        data |= (delay & 0x3) << 2
        return Block(id: id, data: data)
    }
}
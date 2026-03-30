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

enum Material {
    case rock
    case iron
    case todo
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
    static let lockedChest = Block(id: 95)
    static let trapdoor = TrapdoorBuilder()
}
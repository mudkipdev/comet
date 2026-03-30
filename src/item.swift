import NIOCore

struct Item: RawRepresentable, Equatable {
    let rawValue: Int16
    var maxStackSize: Int8 { 64 }

    static let air = Item(rawValue: -1)

    static let ironShovel = Item(rawValue: 256)
    static let ironPickaxe = Item(rawValue: 257)
    static let ironAxe = Item(rawValue: 258)
    static let flintAndSteel = Item(rawValue: 259)
    static let apple = Item(rawValue: 260)
    static let bow = Item(rawValue: 261)
    static let arrow = Item(rawValue: 262)
    static let coal = Item(rawValue: 263)
    static let diamond = Item(rawValue: 264)
    static let iron = Item(rawValue: 265)
    static let gold = Item(rawValue: 266)
    static let ironSword = Item(rawValue: 267)

    static let woodenSword = Item(rawValue: 268)
    static let woodenShovel = Item(rawValue: 269)
    static let woodenPickaxe = Item(rawValue: 270)
    static let woodenAxe = Item(rawValue: 271)

    static let stoneSword = Item(rawValue: 272)
    static let stoneShovel = Item(rawValue: 273)
    static let stonePickaxe = Item(rawValue: 274)
    static let stoneAxe = Item(rawValue: 275)

    static let diamondSword = Item(rawValue: 276)
    static let diamondShovel = Item(rawValue: 277)
    static let diamondPickaxe = Item(rawValue: 278)
    static let diamondAxe = Item(rawValue: 279)

    static let stick = Item(rawValue: 280)
    static let bowl = Item(rawValue: 281)
    static let mushroomStew = Item(rawValue: 282)

    static let goldSword = Item(rawValue: 283)
    static let goldShovel = Item(rawValue: 284)
    static let goldPickaxe = Item(rawValue: 285)
    static let goldAxe = Item(rawValue: 286)

    static let string = Item(rawValue: 287)
    static let feather = Item(rawValue: 288)
    static let gunpowder = Item(rawValue: 289)

    static let woodenHoe = Item(rawValue: 290)
    static let stoneHoe = Item(rawValue: 291)
    static let ironHoe = Item(rawValue: 292)
    static let diamondHoe = Item(rawValue: 293)
    static let goldHoe = Item(rawValue: 294)

    static let seeds = Item(rawValue: 295)
    static let wheat = Item(rawValue: 296)
    static let bread = Item(rawValue: 297)

    static let leatherCap = Item(rawValue: 298)
    static let leatherTunic = Item(rawValue: 299)
    static let leatherPants = Item(rawValue: 300)
    static let leatherBoots = Item(rawValue: 301)
    static let chainmailHelmet = Item(rawValue: 302)
    static let chainmailChestplate = Item(rawValue: 303)
    static let chainmailLeggings = Item(rawValue: 304)
    static let chainmailBoots = Item(rawValue: 305)
    static let ironHelmet = Item(rawValue: 306)
    static let ironChestplate = Item(rawValue: 307)
    static let ironLeggings = Item(rawValue: 308)
    static let ironBoots = Item(rawValue: 309)
    static let diamondHelmet = Item(rawValue: 310)
    static let diamondChestplate = Item(rawValue: 311)
    static let diamondLeggings = Item(rawValue: 312)
    static let diamondBoots = Item(rawValue: 313)
    static let goldHelmet = Item(rawValue: 314)
    static let goldChestplate = Item(rawValue: 315)
    static let goldLeggings = Item(rawValue: 316)
    static let goldBoots = Item(rawValue: 317)

    static let flint = Item(rawValue: 318)
    static let porkchop = Item(rawValue: 319)
    static let cookedPorkchop = Item(rawValue: 320)
    static let painting = Item(rawValue: 321)
    static let goldenApple = Item(rawValue: 322)
    static let sign = Item(rawValue: 323)
    static let woodenDoor = Item(rawValue: 324)
    static let bucket = Item(rawValue: 325)
    static let waterBucket = Item(rawValue: 326)
    static let lavaBucket = Item(rawValue: 327)
    static let minecart = Item(rawValue: 328)
    static let saddle = Item(rawValue: 329)
    static let ironDoor = Item(rawValue: 330)
    static let redstone = Item(rawValue: 331)
    static let snowball = Item(rawValue: 332)
    static let boat = Item(rawValue: 333)
    static let leather = Item(rawValue: 334)
    static let milkBucket = Item(rawValue: 335)
    static let brick = Item(rawValue: 336)
    static let clay = Item(rawValue: 337)
    static let sugarcane = Item(rawValue: 338)
    static let paper = Item(rawValue: 339)
    static let book = Item(rawValue: 340)
    static let slime = Item(rawValue: 341)
    static let chestMinecart = Item(rawValue: 342)
    static let furnaceMinecart = Item(rawValue: 343)
    static let egg = Item(rawValue: 344)
    static let compass = Item(rawValue: 345)
    static let fishingRod = Item(rawValue: 346)
    static let clock = Item(rawValue: 347)
    static let glowstoneDust = Item(rawValue: 348)
    static let fish = Item(rawValue: 349)
    static let cookedFish = Item(rawValue: 350)
    static let dye = Item(rawValue: 351)
    static let bone = Item(rawValue: 352)
    static let sugar = Item(rawValue: 353)
    static let cake = Item(rawValue: 354)
    static let bed = Item(rawValue: 355)
    static let redstoneRepeater = Item(rawValue: 356)
    static let cookie = Item(rawValue: 357)
    static let map = Item(rawValue: 358)
    static let shears = Item(rawValue: 359)
    static let musicDisc13 = Item(rawValue: 2256)
    static let musicDiscCat = Item(rawValue: 2257)
}


struct ItemStack {
    static let air = ItemStack(item: .air)

    var item: Item
    var amount: Int8 = 1
    var metadata: Int16 = 0

    var id: Int16 {
        item.rawValue
    }

    var empty: Bool {
        item == .air || amount <= 0
    }

    init(id: Int16, amount: Int8 = 1, metadata: Int16 = 0) {
        self.item = Item(rawValue: id) // bruh
        self.amount = amount
        self.metadata = metadata
    }

    init(item: Item, amount: Int8 = 1, metadata: Int16 = 0) {
        self.item = item
        self.amount = amount
        self.metadata = metadata
    }

    init(block: BlockLike, amount: Int8 = 1) {
        let blockState = block.asBlock()
        self.init(item: Item(rawValue: Int16(blockState.id)), amount: amount, metadata: Int16(blockState.data))
    }

    init(from buffer: inout ByteBuffer) throws {
        let id: Int16 = try buffer.readInteger()

        if id <= 0 {
            item = .air
            return
        }

        item = Item(rawValue: id)
        amount = try buffer.readInteger()
        metadata = try buffer.readInteger()
    }

    func write(to buffer: inout ByteBuffer) {
        buffer.writeInteger(item.rawValue)

        if item != .air {
            buffer.writeInteger(amount)
            buffer.writeInteger(metadata)
        }
    }

    func withAmount(_ amount: Int8) -> Self {
        if amount < 1 {
            return .air
        }

        return Self(item: item, amount: amount, metadata: metadata)
    }
}

enum ToolTier {
    case wood
    case stone
    case gold
    case iron
    case diamond

    static func from(item: Item) -> ToolTier? {
        switch item {
        case .woodenSword, .woodenShovel, .woodenPickaxe, .woodenAxe, .woodenHoe: .wood
        case .stoneSword, .stoneShovel, .stonePickaxe, .stoneAxe, .stoneHoe: .stone
        case .ironSword, .ironShovel, .ironPickaxe, .ironAxe, .ironHoe: .iron
        case .diamondSword, .diamondShovel, .diamondPickaxe, .diamondAxe, .diamondHoe: .diamond
        case .goldSword, .goldShovel, .goldPickaxe, .goldAxe, .goldHoe: .gold
        default: nil
        }
    }
}

enum ToolType {
    case sword
    case pickaxe
    case axe
    case shovel
    case hoe

    static func from(item: Item) -> ToolType? {
        switch item {
        case .woodenSword, .stoneSword, .ironSword, .diamondSword, .goldSword: .sword
        case .woodenPickaxe, .stonePickaxe, .ironPickaxe, .diamondPickaxe, .goldPickaxe: .pickaxe
        case .woodenAxe, .stoneAxe, .ironAxe, .diamondAxe, .goldAxe: .axe
        case .woodenShovel, .stoneShovel, .ironShovel, .diamondShovel, .goldShovel: .shovel
        case .woodenHoe, .stoneHoe, .ironHoe, .diamondHoe, .goldHoe: .hoe
        default: nil
        }
    }
}
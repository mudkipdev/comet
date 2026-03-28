import NIOCore

protocol OutgoingPacket {
    static var id: UInt8 { get }
    func write(to buffer: inout ByteBuffer) throws
}

struct OutgoingLogin: OutgoingPacket {
    static let id: UInt8 = 0x01
    var entityId: Int32
    var worldSeed: Int64
    var dimension: Dimension

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(entityId)
        buffer.writeString16("")
        buffer.writeInteger(worldSeed)
        buffer.writeInteger(dimension.rawValue)
    }
}

struct OutgoingPreLogin: OutgoingPacket {
    static let id: UInt8 = 0x02
    var connectionHash: String

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeString16(connectionHash)
    }
}

struct SetTime: OutgoingPacket {
    static let id: UInt8 = 0x04
    var time: Int64

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(time)
    }
}

struct SetSpawnPosition: OutgoingPacket {
    static let id: UInt8 = 0x06
    var position: BlockPosition

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(position.x)
        buffer.writeInteger(position.y)
        buffer.writeInteger(position.z)
    }
}

struct SetHealth: OutgoingPacket {
    static let id: UInt8 = 0x08
    var health: Int16

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(health)
    }
}

struct SetChunkVisibility: OutgoingPacket {
    static let id: UInt8 = 0x32
    var x: Int32
    var z: Int32
    var load: Bool

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(x)
        buffer.writeInteger(z)
        buffer.writeBoolean(load)
    }
}

struct ChunkPacket: OutgoingPacket {
    static let id: UInt8 = 0x33
    var x: Int32
    var z: Int32
    var width: Int8
    var height: Int8
    var length: Int8
    var data: [UInt8]

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(x)
        buffer.writeInteger(Int16(0))
        buffer.writeInteger(z)
        buffer.writeInteger(width)
        buffer.writeInteger(height)
        buffer.writeInteger(length)
        buffer.writeInteger(Int32(data.count))
        buffer.writeBytes(data)
    }
}

enum ContainerType: Int8 {
    case chest = 0
    case craftingTable = 1
    case furnace = 2
    case dispenser = 3
}

struct OpenContainer: OutgoingPacket {
    static let id: UInt8 = 0x64
    var windowId: Int8
    var type: ContainerType
    var title: String
    var size: Int8

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(windowId)
        buffer.writeInteger(type.rawValue)
        buffer.writeString8(title)
        buffer.writeInteger(size)
    }
}

struct SetSlot: OutgoingPacket {
    static let id: UInt8 = 0x67
    var windowId: Int8
    var slot: Int16
    var itemStack: ItemStack

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(windowId)
        buffer.writeInteger(slot)
        itemStack.write(to: &buffer)
    }
}

struct FillContainer: OutgoingPacket {
    static let id: UInt8 = 0x68
    var windowId: Int8
    var items: [ItemStack]

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(windowId)
        buffer.writeInteger(Int16(items.count))
        for item in items {
            item.write(to: &buffer)
        }
    }
}

enum ContainerDataType: Int16 {
    case smeltingProgress = 0
    case fuelRemaining = 1
    case fuelDuration = 2
}

struct ContainerData: OutgoingPacket {
    static let id: UInt8 = 0x69
    var windowId: Int8
    var type: ContainerDataType
    var value: Int16

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(windowId)
        buffer.writeInteger(type.rawValue)
        buffer.writeInteger(value)
    }
}
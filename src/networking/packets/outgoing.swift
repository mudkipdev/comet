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

struct SpawnPlayer: OutgoingPacket {
    static let id: UInt8 = 0x14
    var entityId: Int32
    var username: String
    var x: Int32
    var y: Int32
    var z: Int32
    var yaw: Int8
    var pitch: Int8
    var heldItem: Int16

    init(player: Player) {
        entityId = player.id
        username = player.username
        x = Int32(player.position.x)
        y = Int32(player.position.y)
        z = Int32(player.position.z)
        yaw = Int8(truncatingIfNeeded: Int32((player.position.yaw / 360.0) * 255.0))
        pitch = Int8(truncatingIfNeeded: Int32((player.position.pitch / 360.0) * 255.0))
        heldItem = 0
    }

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(entityId)
        buffer.writeString16(username)
        buffer.writeInteger(x)
        buffer.writeInteger(y)
        buffer.writeInteger(z)
        buffer.writeInteger(yaw)
        buffer.writeInteger(pitch)
        buffer.writeInteger(heldItem)
    }
}

struct DespawnEntity: OutgoingPacket {
    static let id: UInt8 = 0x1D
    var entityId: Int32

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(entityId)
    }
}

struct TeleportEntity: OutgoingPacket {
    static let id: UInt8 = 0x22
    var entityId: Int32
    var x: Int32
    var y: Int32
    var z: Int32
    var yaw: Int8
    var pitch: Int8

    init(entity: Entity) {
        entityId = entity.id
        x = Int32(entity.position.x * 32)
        y = Int32(entity.position.y * 32)
        z = Int32(entity.position.z * 32)
        yaw = Int8(truncatingIfNeeded: Int32((entity.position.yaw / 360.0) * 255.0))
        pitch = Int8(truncatingIfNeeded: Int32((entity.position.pitch / 360.0) * 255.0))
    }

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(entityId)
        buffer.writeInteger(x)
        buffer.writeInteger(y)
        buffer.writeInteger(z)
        buffer.writeInteger(yaw)
        buffer.writeInteger(pitch)
    }
}

struct EntityMetadata: OutgoingPacket {
    static let id: UInt8 = 0x28
    var entityId: Int32
    var tracker: DataTracker

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(entityId)
        tracker.write(to: &buffer)
    }
}

struct SetBlock: OutgoingPacket {
    static let id: UInt8 = 0x35
    var x: Int32
    var y: Int8
    var z: Int32
    var type: UInt8
    var metadata: UInt8

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(x)
        buffer.writeInteger(y)
        buffer.writeInteger(z)
        buffer.writeInteger(type)
        buffer.writeInteger(metadata)
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
import NIOCore

protocol IncomingPacket {
    init(from buffer: inout ByteBuffer) throws
}

struct IncomingLogin: IncomingPacket {
    var protocolVersion: Int32
    var username: String

    init(from buffer: inout ByteBuffer) throws {
        protocolVersion = try buffer.readInteger()
        username = try buffer.readString16()
        let _: Int64 = try buffer.readInteger()
        let _: Int8 = try buffer.readInteger()
    }
}

struct IncomingPreLogin: IncomingPacket {
    var username: String

    init(from buffer: inout ByteBuffer) throws {
        username = try buffer.readString16()
    }
}

struct InteractWithEntity: IncomingPacket {
    var playerId: Int32
    var entityId: Int32
    var isAttack: Bool

    init(from buffer: inout ByteBuffer) throws {
        playerId = try buffer.readInteger()
        entityId = try buffer.readInteger()
        isAttack = try buffer.readBoolean()
    }
}

struct MineBlock: IncomingPacket {
    var status: Int8
    var x: Int32
    var y: Int8
    var z: Int32
    var face: Int8

    init(from buffer: inout ByteBuffer) throws {
        status = try buffer.readInteger()
        x = try buffer.readInteger()
        y = try buffer.readInteger()
        z = try buffer.readInteger()
        face = try buffer.readInteger()
    }
}

struct PlaceBlock: IncomingPacket {
    var x: Int32
    var y: Int8
    var z: Int32
    var face: Int8
    var itemStack: ItemStack

    init(from buffer: inout ByteBuffer) throws {
        x = try buffer.readInteger()
        y = try buffer.readInteger()
        z = try buffer.readInteger()
        face = try buffer.readInteger()
        itemStack = try ItemStack(from: &buffer)
    }
}

struct SetHotbarSlot: IncomingPacket {
    var slot: Int16

    init(from buffer: inout ByteBuffer) throws {
        slot = try buffer.readInteger()
    }
}

enum ActionType: Int8 {
    case startSneaking = 1
    case stopSneaking = 2
    case leaveBed = 3
}

struct PlayerAction: IncomingPacket {
    var entityId: Int32
    var type: ActionType

    init(from buffer: inout ByteBuffer) throws {
        entityId = try buffer.readInteger()
        type = ActionType(rawValue: try buffer.readInteger())!
    }
}
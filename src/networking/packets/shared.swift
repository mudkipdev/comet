import NIOCore

typealias SharedPacket = IncomingPacket & OutgoingPacket

struct KeepAlive: SharedPacket {
    static let id: UInt8 = 0x00
    init() {}

    init(from buffer: inout ByteBuffer) throws {}

    func write(to buffer: inout ByteBuffer) throws {}
}

struct ChatMessage: SharedPacket {
    static let id: UInt8 = 0x03
    var message: String
}

extension ChatMessage {
    init(from buffer: inout ByteBuffer) throws {
        message = try buffer.readString16()
    }

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeString16(message)
    }
}

struct PlayerMovement: SharedPacket {
    static let id: UInt8 = 0x0A
    var onGround: Bool
}

extension PlayerMovement {
    init(from buffer: inout ByteBuffer) throws {
        onGround = try buffer.readBoolean()
    }

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeBoolean(onGround)
    }
}

struct PlayerPosition: SharedPacket {
    static let id: UInt8 = 0x0B
    var x: Double
    var y: Double
    var cameraY: Double
    var z: Double
    var onGround: Bool
}

extension PlayerPosition {
    init(from buffer: inout ByteBuffer) throws {
        x = try buffer.readDouble()
        y = try buffer.readDouble()
        cameraY = try buffer.readDouble()
        z = try buffer.readDouble()
        onGround = try buffer.readBoolean()
    }

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeDouble(x)
        buffer.writeDouble(y)
        buffer.writeDouble(cameraY)
        buffer.writeDouble(z)
        buffer.writeBoolean(onGround)
    }
}

struct PlayerRotation: SharedPacket {
    static let id: UInt8 = 0x0C
    var yaw: Float
    var pitch: Float
    var onGround: Bool
}

extension PlayerRotation {
    init(from buffer: inout ByteBuffer) throws {
        yaw = try buffer.readFloat()
        pitch = try buffer.readFloat()
        onGround = try buffer.readBoolean()
    }

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeFloat(yaw)
        buffer.writeFloat(pitch)
        buffer.writeBoolean(onGround)
    }
}

struct PlayerPositionAndRotation: SharedPacket {
    static let id: UInt8 = 0x0D
    var x: Double
    var y: Double
    var cameraY: Double
    var z: Double
    var yaw: Float
    var pitch: Float
    var onGround: Bool
}

extension PlayerPositionAndRotation {
    init(from buffer: inout ByteBuffer) throws {
        x = try buffer.readDouble()
        y = try buffer.readDouble()
        cameraY = try buffer.readDouble()
        z = try buffer.readDouble()
        yaw = try buffer.readFloat()
        pitch = try buffer.readFloat()
        onGround = try buffer.readBoolean()
    }

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeDouble(x)
        buffer.writeDouble(y)
        buffer.writeDouble(cameraY)
        buffer.writeDouble(z)
        buffer.writeFloat(yaw)
        buffer.writeFloat(pitch)
        buffer.writeBoolean(onGround)
    }
}

struct Disconnect: SharedPacket {
    static let id: UInt8 = 0xFF
    var reason: String
}

extension Disconnect {
    init(from buffer: inout ByteBuffer) throws {
        reason = try buffer.readString16()
    }

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeString16(reason)
    }
}

struct Respawn: SharedPacket {
    static let id: UInt8 = 0x09
    var dimension: Dimension
}

extension Respawn {
    init(from buffer: inout ByteBuffer) throws {
        let raw: Int8 = try buffer.readInteger()
        dimension = Dimension(rawValue: raw) ?? .overworld
    }

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(dimension.rawValue)
    }
}

enum AnimationType: Int8 {
    case swingArm = 1
    case leaveBed = 3
}

struct Animation: SharedPacket {
    static let id: UInt8 = 0x12
    var playerId: Int32
    var type: AnimationType
}

extension Animation {
    init(from buffer: inout ByteBuffer) throws {
        playerId = try buffer.readInteger()
        let raw: Int8 = try buffer.readInteger()
        type = AnimationType(rawValue: raw)!
    }

    func write(to buffer: inout ByteBuffer) throws {
        buffer.writeInteger(playerId)
        buffer.writeInteger(type.rawValue)
    }
}
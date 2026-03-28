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

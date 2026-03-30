import NIOCore

enum MetadataValue {
    case byte(Int8)
    case short(Int16)
    case integer(Int32)
    case float(Float)
    case string(String)
    case itemStack(itemStack: ItemStack)
    case coordinates(position: BlockPosition)

    var id: UInt8 {
        switch self {
        case .byte:
            return 0
        case .short:
            return 1
        case .integer:
            return 2
        case .float:
            return 3
        case .string:
            return 4
        case .itemStack:
            return 5
        case .coordinates:
            return 6
        }
    }

    func write(to buffer: inout ByteBuffer) {
        switch self {
        case .byte(let value):
            buffer.writeInteger(value)
        case .short(let value):
            buffer.writeInteger(value)
        case .integer(let value):
            buffer.writeInteger(value)
        case .float(let value):
            buffer.writeFloat(value)
        case .string(let value):
            buffer.writeString16(value)
        case .itemStack(let itemStack):
            buffer.writeInteger(itemStack.id)
            buffer.writeInteger(itemStack.amount)
            buffer.writeInteger(itemStack.metadata)
        case .coordinates(let position):
            buffer.writeInteger(position.x)
            buffer.writeInteger(position.y)
            buffer.writeInteger(position.z)
        }
    }
}

class DataTracker {
    let entity: Entity
    private var entries: [(id: Int, value: MetadataValue)] = []

    init(entity: Entity) {
        self.entity = entity
    }

    func set(id: Int, _ value: MetadataValue) {
        if let index = entries.firstIndex(where: { $0.id == id }) {
            entries[index].value = value
        } else {
            entries.append((id: id, value: value))
        }

        entity.world.sendPacket(EntityMetadata(entityId: entity.id, tracker: self))
    }

    func write(to buffer: inout ByteBuffer) {
        for entry in entries {
            let header = UInt8((entry.value.id << 5) | UInt8(entry.id & 0x1F))
            buffer.writeInteger(header)
            entry.value.write(to: &buffer)
        }

        buffer.writeInteger(UInt8(0x7F))
    }
}

class Entity {
    let world: World
    var position: Position
    let id: Int32
    lazy var dataTracker = DataTracker(entity: self)

    init(world: World, position: Position) {
        self.world = world
        self.position = position
        self.id = world.allocateEntityId()
    }
}

class Player: Entity, PacketReceiver {
    private let channel: Channel?
    let username: String

    var sneaking: Bool = false {
        didSet {
            dataTracker.set(id: 0, .byte(sneaking ? 0x02 : 0x00))
        }
    }

    init(channel: Channel? = nil, world: World, position: Position, username: String) {
        self.channel = channel
        self.username = username
        super.init(world: world, position: position)
    }

    func sendPacket(_ packet: OutgoingPacket) throws {
        guard let channel else { return }
        var buffer = ByteBuffer()
        buffer.writeInteger(type(of: packet).id)
        try packet.write(to: &buffer)
        channel.writeAndFlush(buffer, promise: nil)
    }
}
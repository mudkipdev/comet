import NIOCore

class Entity {
    let world: World
    var position: Position
    let entityId: Int32

    init(world: World, position: Position) {
        self.world = world
        self.position = position
        self.entityId = world.allocateEntityId()
    }
}

class Player: Entity {
    private let channel: Channel?
    let username: String

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

    func sendMessage(_ message: String) {
        try? sendPacket(ChatMessage(message: message))
    }
}
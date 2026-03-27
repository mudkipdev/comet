import NIOCore

class Entity {
    var entityId: Int32
    var position = Position()

    init(entityId: Int32) {
        self.entityId = entityId
    }
}

class Player: Entity {
    var username: String
    private let channel: Channel?

    init(entityId: Int32, username: String, channel: Channel? = nil) {
        self.username = username
        self.channel = channel
        super.init(entityId: entityId)
    }

    func sendPacket(_ packet: OutgoingPacket) throws {
        guard let channel else { return }
        var buffer = ByteBuffer()
        buffer.writeInteger(type(of: packet).id)
        try packet.write(to: &buffer)
        channel.writeAndFlush(buffer, promise: nil)
    }
}

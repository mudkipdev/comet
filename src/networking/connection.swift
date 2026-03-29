import NIOCore

class Connection {
    var player: Player?
    let world: World
    let channel: Channel
    var response = ByteBuffer()

    init(world: World, channel: Channel) {
        self.world = world
        self.channel = channel
    }

    func send(_ packet: OutgoingPacket) throws {
        response.writeInteger(type(of: packet).id)
        try packet.write(to: &response)
    }
}

protocol PacketReceiver {
    func sendPacket(_ packet: OutgoingPacket) throws
}

extension PacketReceiver {
    func sendMessage(_ message: String) {
        try? sendPacket(ChatMessage(message: message))
    }
}
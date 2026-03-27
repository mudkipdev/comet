import NIOCore

struct PacketRegistry: @unchecked Sendable {
    private var handlers: [UInt8: (inout ByteBuffer, Connection) throws -> Void] = [:]

    mutating func register<P: IncomingPacket>(_ id: UInt8, _: P.Type, handler: @escaping (P, Connection) throws -> Void) {
        handlers[id] = { buffer, connection in
            let packet = try P(from: &buffer)
            try handler(packet, connection)
        }
    }

    mutating func ignore<P: IncomingPacket>(_ id: UInt8, _: P.Type) {
        register(id, P.self) { _, _ in }
    }

    func handle(_ id: UInt8, buffer: inout ByteBuffer, connection: Connection) throws -> Bool {
        guard let handler = handlers[id] else { return false }
        try handler(&buffer, connection)
        return true
    }
}

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

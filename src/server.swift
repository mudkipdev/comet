import NIOCore
import NIOPosix

let ticksPerSecond = 20

final class Server: @unchecked Sendable {
    let port: Int
    let world = World()
    let packetRegistry: PacketRegistry

    private var tickTask: Task<Void, Never>?

    init(port: Int = 25565) {
        self.port = port
        self.packetRegistry = Server.buildRegistry()
    }

    func start() async throws {
        let server = try await ServerBootstrap(group: NIOSingletons.posixEventLoopGroup)
            .serverChannelOption(.socketOption(.so_reuseaddr), value: 1)
            .bind(host: "0.0.0.0", port: port) { channel in
                channel.eventLoop.makeCompletedFuture {
                    try NIOAsyncChannel<ByteBuffer, ByteBuffer>(wrappingChannelSynchronously: channel)
                }
            }

        print("Started server on port \(port).")

        tickTask = Task {
            await self.tick()
        }

        try await server.executeThenClose { clients in
            for try await client in clients {
                do {
                    try await self.handleConnection(client)
                } catch {
                    print("Connection error: \(error)")
                }
            }
        }
    }

    func stop() {
        tickTask?.cancel()
        tickTask = nil
    }

    private func tick() async {
        let interval = Duration.milliseconds(1000 / ticksPerSecond)

        while !Task.isCancelled {
            world.tick()
            try? await Task.sleep(for: interval)
        }
    }

    private func handleConnection(_ channel: NIOAsyncChannel<ByteBuffer, ByteBuffer>) async throws {
        try await channel.executeThenClose { inbound, outbound in
            let connection = Connection(world: self.world, channel: channel.channel)

            defer {
                if let player = connection.player {
                    self.world.removePlayer(player)
                }
            }

            for try await var buffer in inbound {
                while buffer.readableBytes > 0 {
                    let id: UInt8 = try buffer.readInteger()

                    if id == 0xFF {
                        let _ = try Disconnect(from: &buffer)

                        if let player = connection.player {
                            print("\(player.username) disconnected.")
                        }

                        return
                    }

                    if try !self.packetRegistry.handle(id, buffer: &buffer, connection: connection) {
                        let name = connection.player?.username ?? "unknown"
                        print("Unknown packet ID 0x\(String(format: "%02X", id)) from \(name).")
                        try connection.send(Disconnect(reason: "Unknown packet"))
                        try await outbound.write(connection.response)
                        return
                    }

                    if connection.response.readableBytes > 0 {
                        try await outbound.write(connection.response)
                        connection.response = ByteBuffer()
                    }
                }
            }

            if let player = connection.player {
                print("\(player.username) lost connection.")
            }
        }
    }

    private static func buildRegistry() -> PacketRegistry {
        var registry = PacketRegistry()

        registry.register(0x00, KeepAlive.self) { packet, connection in
            if connection.player != nil {
                try connection.send(packet)
            }
        }

        registry.register(0x01, IncomingLogin.self) { packet, connection in
            let player = Player(
                entityId: connection.world.allocateEntityId(),
                username: packet.username,
                channel: connection.channel
            )

            connection.player = player
            print("\(packet.username) joined the server.")

            let spawnPosition = connection.world.spawnPosition

            try connection.send(OutgoingLogin(
                entityId: player.entityId,
                worldSeed: connection.world.seed,
                dimension: connection.world.dimension
            ))

            try connection.send(SetTime(time: connection.world.time))

            let viewDistance: Int32 = 3

            for chunkX in -viewDistance...viewDistance {
                for chunkZ in -viewDistance...viewDistance {
                    try connection.send(SetChunkVisibility(x: chunkX, z: chunkZ, load: true))
                    let chunk = connection.world.getChunk(chunkX, chunkZ)

                    if let chunkPacket = chunk.createChunkPacket() {
                        try connection.send(chunkPacket)
                    }
                }
            }

            try connection.send(SetSpawnPosition(position: spawnPosition))

            try connection.send(PlayerPositionAndRotation(
                x: Double(spawnPosition.x),
                y: Double(spawnPosition.y),
                cameraY: Double(spawnPosition.y) + 1.62,
                z: Double(spawnPosition.z),
                yaw: 0.0,
                pitch: 0.0,
                onGround: false
            ))

            connection.world.addPlayer(player)
        }

        registry.register(0x02, IncomingPreLogin.self) { packet, connection in
            try connection.send(OutgoingPreLogin(username: "-"))
        }

        registry.register(0x03, ChatMessage.self) { packet, connection in
            if let player = connection.player {
                print("<\(player.username)> \(packet.message)")
            }
        }

        registry.ignore(0x07, InteractWithEntity.self)

        registry.register(0x09, Respawn.self) { _, connection in
            try connection.send(Respawn(dimension: connection.world.dimension))
        }

        registry.ignore(0x0A, PlayerMovement.self)

        registry.register(0x0B, PlayerPosition.self) { packet, connection in
            if let player = connection.player {
                player.position.x = packet.x
                player.position.y = packet.y
                player.position.z = packet.z
            }
        }

        registry.register(0x0C, PlayerRotation.self) { packet, connection in
            if let player = connection.player {
                player.position.yaw = packet.yaw
                player.position.pitch = packet.pitch
            }
        }

        registry.register(0x0D, PlayerPositionAndRotation.self) { packet, connection in
            if let player = connection.player {
                player.position.x = packet.x
                player.position.y = packet.y
                player.position.z = packet.z
                player.position.yaw = packet.yaw
                player.position.pitch = packet.pitch
            }
        }

        // stuff for later
        registry.ignore(0x0E, MineBlock.self)
        registry.ignore(0x0F, PlaceBlock.self)
        registry.ignore(0x10, SetHotbarSlot.self)
        registry.ignore(0x12, Animation.self)
        registry.ignore(0x13, PlayerAction.self)
        return registry
    }
}

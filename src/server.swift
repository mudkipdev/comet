import NIOCore
import NIOPosix

let ticksPerSecond = 20
let viewDistance: Int32 = 4

final class Server: @unchecked Sendable {
    let port: UInt16
    let world = World()
    let packetRegistry: PacketRegistry

    private var tickTask: Task<Void, Never>?

    init(port: UInt16 = 25565) {
        self.port = port
        self.packetRegistry = Server.buildRegistry()
    }

    func start() async throws {
        let server = try await ServerBootstrap(group: NIOSingletons.posixEventLoopGroup)
            .serverChannelOption(.socketOption(.so_reuseaddr), value: 1)
            .bind(host: "0.0.0.0", port: Int(port)) { channel in
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
        try await channel.executeThenClose { inboundStream, outboundStream in
            let connection = Connection(world: self.world, channel: channel.channel)

            // player will be removed from the world when we exit this scope
            defer {
                if let player = connection.player {
                    self.world.removePlayer(player)
                }
            }

            for try await var buffer in inboundStream {
                while buffer.readableBytes > 0 {
                    let id: UInt8 = try buffer.readInteger()

                    if id == 0xFF {
                        let _ = try Disconnect(connection: connection, from: &buffer)

                        if let player = connection.player {
                            world.sendMessage("\(ChatColor.yellow)\(player.username) left the game")
                            print("\(player.username) disconnected.")
                        }

                        return
                    }

                    if try !self.packetRegistry.handle(id, buffer: &buffer, connection: connection) {
                        let name = connection.player?.username ?? "unknown"
                        print("Unknown packet ID 0x\(String(format: "%02X", id)) from \(name).")
                        try connection.send(Disconnect(reason: "Unknown packet"))
                        try await outboundStream.write(connection.response)
                        return
                    }

                    if connection.response.readableBytes > 0 {
                        try await outboundStream.write(connection.response)
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

        registry.ignore(0x00, KeepAlive.self)

        registry.register(0x01, IncomingLogin.self) { packet, connection in
            let spawnPosition = connection.world.spawnPosition

            let player = Player(
                channel: connection.channel,
                world: connection.world,
                position: Position(
                    x: Double(spawnPosition.x) + 0.5,
                    y: Double(spawnPosition.y + 1),
                    z: Double(spawnPosition.z) + 0.5
                ),
                username: packet.username
            )

            connection.player = player
            connection.world.addPlayer(player)
            try handlePlayerLogin(player)
        }

        registry.register(0x02, IncomingPreLogin.self) { packet, connection in
            try connection.send(OutgoingPreLogin(connectionHash: "-"))
        }

        registry.register(0x03, ChatMessage.self) { packet, connection in
            if let player = connection.player {
                let message = "<\(player.username)> \(packet.message)"
                player.world.sendMessage(message)
                print(message)
            }
        }

        registry.ignore(0x07, InteractWithEntity.self)

        registry.register(0x09, Respawn.self) { _, connection in
            try connection.send(Respawn(dimension: connection.world.dimension))
        }

        registry.ignore(0x0A, PlayerMovement.self)

        registry.register(0x0B, PlayerPosition.self) { packet, connection in
            if let player = connection.player {
                player.position = player.position.with(
                    x: packet.x,
                    y: packet.y,
                    z: packet.z
                )
            }
        }

        registry.register(0x0C, PlayerRotation.self) { packet, connection in
            if let player = connection.player {
                player.position = player.position.with(
                    yaw: packet.yaw,
                    pitch: packet.pitch
                )
            }
        }

        registry.register(0x0D, PlayerPositionAndRotation.self) { packet, connection in
            if let player = connection.player {
                player.position = Position(
                    x: packet.x,
                    y: packet.y,
                    z: packet.z,
                    yaw: packet.yaw,
                    pitch: packet.pitch
                )
            }
        }

        // stuff for later
        registry.ignore(0x0E, MineBlock.self)
        registry.ignore(0x0F, PlaceBlock.self)
        registry.ignore(0x10, SetHotbarSlot.self)
        registry.ignore(0x12, Animation.self)
        registry.ignore(0x13, PlayerAction.self)
        registry.ignore(0x65, CloseContainer.self)
        registry.ignore(0x66, ClickSlot.self)
        registry.ignore(0x6A, ContainerTransaction.self)
        return registry
    }

    private static func handlePlayerLogin(_ player: Player) throws {
        print("\(player.username) joined the server.")
        let world = player.world

        try player.sendPacket(OutgoingLogin(
            entityId: player.entityId,
            worldSeed: world.seed,
            dimension: world.dimension
        ))

        try player.sendPacket(SetSpawnPosition(position: world.spawnPosition))
        try player.sendPacket(SetTime(time: world.time))

        for chunkX in -viewDistance...viewDistance {
            for chunkZ in -viewDistance...viewDistance {
                try player.sendPacket(SetChunkVisibility(x: chunkX, z: chunkZ, load: true))
                let chunk = world.getChunk(chunkX, chunkZ)

                if let packet = chunk.createChunkPacket() {
                    try player.sendPacket(packet)
                }
            }
        }

        try player.sendPacket(PlayerPositionAndRotation(position: player.position, onGround: false))
        world.sendMessage("\(ChatColor.yellow)\(player.username) joined the game")
    }
}

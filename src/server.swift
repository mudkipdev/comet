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
                Task {
                    do {
                        try await self.handleConnection(client)
                    } catch {
                        print("Connection error: \(error)")
                    }
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
                        let _ = try Disconnect(from: &buffer)

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

        registry.register(0x0E, MineBlock.self) { packet, connection in
            guard packet.status == 2, let player = connection.player else {
                return
            }

            let world = player.world
            let block = world.getBlock(packet.x, Int32(packet.y), packet.z)
            world.setBlock(packet.x, Int32(packet.y), packet.z, Block.air)
            player.inventory.addItemStack(block.droppedItemStack)
        }

        registry.register(0x0F, PlaceBlock.self) { packet, connection in
            guard let player = connection.player else {
                return
            }

            guard packet.itemStack.id > 0 else {
                return
            }

            var x = packet.x, y = Int32(packet.y), z = packet.z

            switch packet.face {
            case 0: y -= 1
            case 1: y += 1
            case 2: z -= 1
            case 3: z += 1
            case 4: x -= 1
            case 5: x += 1
            default: return
            }

            let block = Block(id: UInt8(packet.itemStack.id), data: UInt8(packet.itemStack.metadata))
            player.heldItem = player.heldItem.withAmount(player.heldItem.amount - 1)
            player.world.setBlock(x, y, z, block)
        }

        registry.ignore(0x10, SetHotbarSlot.self)

        registry.register(0x12, Animation.self) { packet, connection in
            guard let player = connection.player else {
                return
            }

            for otherPlayer in player.world.players where otherPlayer !== player {
                try? otherPlayer.sendPacket(Animation(playerId: player.id, type: packet.type))
            }
        }

        registry.register(0x13, PlayerAction.self) { packet, connection in
            guard let player = connection.player else {
                return
            }

            switch packet.type {
            case .startSneaking: player.sneaking = true
            case .stopSneaking:  player.sneaking = false
            default: break
            }
        }

        registry.ignore(0x65, CloseContainer.self)
        registry.ignore(0x66, ClickSlot.self)
        registry.ignore(0x6A, ContainerTransaction.self)
        return registry
    }

    private static func handlePlayerLogin(_ player: Player) throws {
        print("\(player.username) joined the server.")
        let world = player.world

        try player.sendPacket(OutgoingLogin(
            entityId: player.id,
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

        for otherPlayer in world.players where otherPlayer !== player {
            try? player.sendPacket(SpawnPlayer(player: otherPlayer))
        }
    }
}
import NIOCore
import NIOPosix

let server = try await ServerBootstrap(group: NIOSingletons.posixEventLoopGroup)
    .bind(host: "0.0.0.0", port: 25565) { channel in
        channel.eventLoop.makeCompletedFuture {
            try NIOAsyncChannel<ByteBuffer, ByteBuffer>(wrappingChannelSynchronously: channel)
        }
    }

print("Started server on port 25565.")

try await server.executeThenClose { clients in
    for try await client in clients {
        try await client.executeThenClose { inbound, outbound in
            for try await chunk in inbound {
                try await outbound.write(chunk)
            }
        }
    }
}

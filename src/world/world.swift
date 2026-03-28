import NIOCore

enum Dimension: Int8 {
    case overworld = 0
    case nether = -1
}

let chunkWidth = 16
let worldHeight = 128
let chunkLength = 16

struct Chunk {
    var x: Int32
    var z: Int32

    var blocks = [UInt8](repeating: 0, count: chunkWidth * worldHeight * chunkLength)
    var blockData = [UInt8](repeating: 0, count: chunkWidth * worldHeight * chunkLength / 2)
    var blockLight = [UInt8](repeating: 0xFF, count: chunkWidth * worldHeight * chunkLength / 2)
    var skyLight = [UInt8](repeating: 0xFF, count: chunkWidth * worldHeight * chunkLength / 2)

    private func blockIndex(_ x: Int, _ y: Int, _ z: Int) -> Int {
        y + (z * worldHeight) + (x * worldHeight * chunkLength)
    }

    func getBlock(_ x: Int, _ y: Int, _ z: Int) -> UInt8 {
        blocks[blockIndex(x, y, z)]
    }

    mutating func setBlock(_ x: Int, _ y: Int, _ z: Int, _ block: UInt8) {
        blocks[blockIndex(x, y, z)] = block
    }

    func createChunkPacket() -> ChunkPacket? {
        let input = blocks + blockData + blockLight + skyLight
        guard let compressedData = zlibCompress(input) else { return nil }

        return ChunkPacket(
            x: x * Int32(chunkWidth),
            z: z * Int32(chunkLength),
            width: Int8(chunkWidth - 1),
            height: Int8(worldHeight - 1),
            length: Int8(chunkLength - 1),
            data: compressedData
        )
    }
}

struct ChunkCoordinates: Hashable {
    var x: Int32
    var z: Int32
}

final class World: @unchecked Sendable {
    var seed: Int64 = 0
    var dimension: Dimension = .overworld
    var spawnPosition = BlockPosition(x: 0, y: 68, z: 0)
    var chunks: [ChunkCoordinates: Chunk] = [:]
    var nextEntityId: Int32 = 1
    var time: Int64 = 0
    var ticks: Int = 0

    let generator: WorldGenerator
    private var players: [Player] = []

    init(seed: Int64 = 0, generator: WorldGenerator? = nil) {
        self.seed = seed
        self.generator = generator ?? DefaultWorldGenerator(seed: seed)
    }

    func addPlayer(_ player: Player) {
        players.append(player)
    }

    func removePlayer(_ player: Player) {
        players.removeAll { $0 === player }
    }

    func broadcast(_ packet: OutgoingPacket) {
        for player in players {
            try? player.sendPacket(packet)
        }
    }

    func tick() {
        time += 1
        ticks += 1

        // send a keep alive packet every second
        if ticks % ticksPerSecond == 0 {
            broadcast(KeepAlive())
        }
    }

    func allocateEntityId() -> Int32 {
        let id = nextEntityId
        nextEntityId += 1
        return id
    }

    func getBlock(_ x: Int32, _ y: Int32, _ z: Int32) -> Block {
        let chunk = getChunk(x >> 4, z >> 4)
        return Block(rawValue: chunk.getBlock(Int(x & 0xF), Int(y), Int(z & 0xF))) ?? .air
    }

    func setBlock(_ x: Int32, _ y: Int32, _ z: Int32, _ block: Block) {
        let chunkX = x >> 4
        let chunkZ = z >> 4
        let coordinates = ChunkCoordinates(x: chunkX, z: chunkZ)
        var chunk = getChunk(chunkX, chunkZ)
        chunk.setBlock(Int(x & 0xF), Int(y), Int(z & 0xF), block.rawValue)
        chunks[coordinates] = chunk
    }

    func getChunk(_ x: Int32, _ z: Int32) -> Chunk {
        let coordinates = ChunkCoordinates(x: x, z: z)

        if let chunk = chunks[coordinates] {
            return chunk
        }

        var chunk = Chunk(x: x, z: z)
        generator.generate(&chunk)
        chunks[coordinates] = chunk
        return chunk
    }
}

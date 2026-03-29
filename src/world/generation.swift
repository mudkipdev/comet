protocol WorldGenerator {
    func generate(_ chunk: inout Chunk)
}

struct DefaultWorldGenerator: WorldGenerator {
    let seed: Int64
    let noise: OctaveNoise

    init(seed: Int64) {
        self.seed = seed
        self.noise = OctaveNoise(seed: seed, octaves: 4, frequency: 0.01)
    }

    func generate(_ chunk: inout Chunk) {
        let baseHeight = 64
        var heightMap = [[Int]](repeating: [Int](repeating: 0, count: chunkLength), count: chunkWidth)

        for x in 0..<chunkWidth {
            for z in 0..<chunkLength {
                let worldX = Double(Int(chunk.x) * chunkWidth + x)
                let worldZ = Double(Int(chunk.z) * chunkLength + z)

                let n = noise.evaluate(worldX, worldZ)
                let height = min(worldHeight - 1, max(1, baseHeight + Int(n * 16)))
                heightMap[x][z] = height

                for y in 0..<height {
                    if y == 0 {
                        chunk.setBlock(x, y, z, Block.bedrock)
                    } else if y < height - 4 {
                        chunk.setBlock(x, y, z, Block.stone)
                    } else if y < height - 1 {
                        chunk.setBlock(x, y, z, Block.dirt)
                    } else {
                        chunk.setBlock(x, y, z, Block.grass)

                        if chunk.x == 0 && chunk.z == 0 && x == 0 && z == 0 {
                            chunk.setBlock(x, y + 1, z, Block.woodenStairs.facing(.east))
                        }
                    }
                }
            }
        }

        placeTrees(&chunk, heightMap: heightMap)
    }

    private func placeTrees(_ chunk: inout Chunk, heightMap: [[Int]]) {
        var rng = ChunkRNG(chunkX: chunk.x, chunkZ: chunk.z, seed: seed)

        let treeCount = 2 + rng.nextInt(bound: 4)

        for _ in 0..<treeCount {
            let x = 3 + rng.nextInt(bound: chunkWidth - 6)
            let z = 3 + rng.nextInt(bound: chunkLength - 6)
            let y = heightMap[x][z]

            if chunk.getBlock(x, y - 1, z).id != Block.grass.id {
                continue
            }

            let height = 4 + rng.nextInt(bound: 3)

            if y + height + 1 >= worldHeight {
                continue
            }

            if !canPlaceTree(chunk, x: x, y: y, z: z, height: height) {
                continue
            }

            placeTree(&chunk, x: x, y: y, z: z, height: height, rng: &rng)
        }
    }

    private func canPlaceTree(_ chunk: Chunk, x: Int, y: Int, z: Int, height: Int) -> Bool {
        for yy in y...(y + height + 1) {
            let radius = yy == y ? 0 : (yy >= y + height - 2 ? 2 : 1)

            for xx in (x - radius)...(x + radius) {
                for zz in (z - radius)...(z + radius) {
                    if xx < 0 || xx >= chunkWidth || zz < 0 || zz >= chunkLength {
                        return false
                    }

                    if yy < 0 || yy >= worldHeight {
                        return false
                    }

                    let block = chunk.getBlock(xx, yy, zz)

                    if block.id != Block.air.id && block.id != Block.leaves.id {
                        return false
                    }
                }
            }
        }

        return true
    }

    private func placeTree(_ chunk: inout Chunk, x: Int, y: Int, z: Int, height: Int, rng: inout ChunkRNG) {
        for yy in (y - 3 + height)...(y + height) {
            let dy = yy - (y + height)
            let radius = 1 - dy / 2

            for xx in (x - radius)...(x + radius) {
                for zz in (z - radius)...(z + radius) {
                    if xx < 0 || xx >= chunkWidth || zz < 0 || zz >= chunkLength || yy < 0 || yy >= worldHeight {
                        continue
                    }

                    let cornerX = abs(xx - x) == radius
                    let cornerZ = abs(zz - z) == radius
                    if cornerX && cornerZ && rng.nextInt(bound: 2) == 0 && dy == 0 { continue }

                    if chunk.getBlock(xx, yy, zz).id == Block.air.id {
                        chunk.setBlock(xx, yy, zz, Block.leaves)
                    }
                }
            }
        }

        for yy in 0..<height {
            chunk.setBlock(x, y + yy, z, Block.log)
        }

        chunk.setBlock(x, y - 1, z, Block.dirt)
    }
}

struct FlatWorldGenerator: WorldGenerator {
    func generate(_ chunk: inout Chunk) {
        for x in 0..<chunkWidth {
            for z in 0..<chunkLength {
                chunk.setBlock(x, 0, z, Block.bedrock)

                for y in 1..<4 {
                    chunk.setBlock(x, y, z, Block.dirt)
                }

                chunk.setBlock(x, 4, z, Block.grass)
            }
        }
    }
}

struct ChunkRNG {
    private var state: UInt64

    init(chunkX: Int32, chunkZ: Int32, seed: Int64) {
        state = UInt64(bitPattern: seed) ^ (UInt64(UInt32(bitPattern: chunkX)) << 32 | UInt64(UInt32(bitPattern: chunkZ)))
        for _ in 0..<4 { _ = next() }
    }

    private mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        z = z ^ (z >> 31)
        return z
    }

    mutating func nextInt(bound: Int) -> Int {
        Int(next() % UInt64(bound))
    }
}
import Foundation

protocol NoiseGenerator {
    init(seed: Int64)
    func evaluate(_ x: Double, _ z: Double) -> Double
}

struct SimplexNoise: NoiseGenerator {
    private let perm: [UInt8]

    // Skew and unskew factors for 2D simplex
    private static let F2 = 0.5 * (3.0.squareRoot() - 1.0)
    private static let G2 = (3.0 - 3.0.squareRoot()) / 6.0

    // 12 gradient directions
    private static let grad: [(Double, Double)] = [
        ( 1,  1), (-1,  1), ( 1, -1), (-1, -1),
        ( 1,  0), (-1,  0), ( 0,  1), ( 0, -1),
        ( 1,  1), (-1,  1), ( 1, -1), (-1, -1),
    ]

    init(seed: Int64) {
        var p = [UInt8](0..<255) + [255]
        var state = UInt64(bitPattern: seed)

        // Fisher-Yates shuffle with splitmix64
        for i in stride(from: 255, through: 1, by: -1) {
            state &+= 0x9E3779B97F4A7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
            z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
            z = z ^ (z >> 31)
            let j = Int(z % UInt64(i + 1))
            p.swapAt(i, j)
        }

        perm = p + p
    }

    func evaluate(_ x: Double, _ z: Double) -> Double {
        let s = (x + z) * Self.F2
        let i = Int(floor(x + s))
        let j = Int(floor(z + s))

        let t = Double(i + j) * Self.G2
        let x0 = x - Double(i) + t
        let z0 = z - Double(j) + t

        let (i1, j1): (Int, Int)
        if x0 > z0 {
            i1 = 1; j1 = 0
        } else {
            i1 = 0; j1 = 1
        }

        let x1 = x0 - Double(i1) + Self.G2
        let z1 = z0 - Double(j1) + Self.G2
        let x2 = x0 - 1.0 + 2.0 * Self.G2
        let z2 = z0 - 1.0 + 2.0 * Self.G2

        let ii = i & 255
        let jj = j & 255

        let n0 = corner(x0, z0, Int(perm[ii &+ Int(perm[jj])]))
        let n1 = corner(x1, z1, Int(perm[ii &+ i1 &+ Int(perm[jj &+ j1])]))
        let n2 = corner(x2, z2, Int(perm[ii &+ 1 &+ Int(perm[jj &+ 1])]))

        // Scale to [-1, 1]
        return 70.0 * (n0 + n1 + n2)
    }

    private func corner(_ x: Double, _ z: Double, _ gi: Int) -> Double {
        var t = 0.5 - x * x - z * z
        if t < 0 { return 0 }
        t *= t
        let g = Self.grad[gi % 12]
        return t * t * (g.0 * x + g.1 * z)
    }
}

struct OctaveNoise: NoiseGenerator {
    private let octaves: [SimplexNoise]
    private let persistence: Double
    private let lacunarity: Double
    private let frequency: Double

    init(seed: Int64) {
        self.init(seed: seed, octaves: 4, frequency: 0.01, persistence: 0.5, lacunarity: 2.0)
    }

    init(seed: Int64, octaves: Int, frequency: Double = 0.01, persistence: Double = 0.5, lacunarity: Double = 2.0) {
        self.frequency = frequency
        self.persistence = persistence
        self.lacunarity = lacunarity

        self.octaves = (0..<octaves).map { i in
            SimplexNoise(seed: seed &+ Int64(i) &* 31)
        }
    }

    func evaluate(_ x: Double, _ z: Double) -> Double {
        var total = 0.0
        var amplitude = 1.0
        var freq = frequency
        var maxAmplitude = 0.0

        for octave in octaves {
            total += octave.evaluate(x * freq, z * freq) * amplitude
            maxAmplitude += amplitude
            amplitude *= persistence
            freq *= lacunarity
        }

        return total / maxAmplitude
    }
}

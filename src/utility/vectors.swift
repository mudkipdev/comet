struct Position {
    let x: Double
    let y: Double
    let z: Double
    let yaw: Float
    let pitch: Float

    init(x: Double, y: Double, z: Double, yaw: Float = 0.0, pitch: Float = 0.0) {
        self.x = x
        self.y = y
        self.z = z
        self.yaw = yaw
        self.pitch = pitch
    }

    func with(
        x: Double? = nil,
        y: Double? = nil,
        z: Double? = nil,
        yaw: Float? = nil,
        pitch: Float? = nil
    ) -> Self {
        return Self(
            x: x ?? self.x,
            y: y ?? self.y,
            z: z ?? self.z,
            yaw: yaw ?? self.yaw,
            pitch: pitch ?? self.pitch
        )
    }

    func add(x: Double = 0.0, y: Double = 0.0, z: Double = 0.0) -> Self {
        return Self(
            x: self.x + x,
            y: self.y + y,
            z: self.z + z,
            yaw: self.yaw,
            pitch: self.pitch
        )
    }

    func subtract(x: Double = 0.0, y: Double = 0.0, z: Double = 0.0) -> Self {
        return self.add(x: -x, y: -y, z: -z)
    }
}

struct BlockPosition {
    let x: Int32
    let y: Int32
    let z: Int32

    func with(x: Int32? = nil, y: Int32? = nil, z: Int32? = nil) -> Self {
        return Self(
            x: x ?? self.x,
            y: y ?? self.y,
            z: z ?? self.z
        )
    }

    func add(x: Int32 = 0, y: Int32 = 0, z: Int32 = 0) -> Self {
        return Self(
            x: self.x + x,
            y: self.y + y,
            z: self.z + z
        )
    }

    func subtract(x: Int32 = 0, y: Int32 = 0, z: Int32 = 0) -> Self {
        return self.add(x: -x, y: -y, z: -z)
    }
}
struct Position {
    var x: Double = 0.0
    var y: Double = 0.0
    var z: Double = 0.0
    var yaw: Float = 0.0
    var pitch: Float = 0.0
}

struct BlockPosition {
    var x: Int32 = 0
    var y: Int32 = 0
    var z: Int32 = 0
}

func spawnPositionToPosition(_ spawnPosition: BlockPosition) -> Position {
    return Position(
        x: Double(spawnPosition.x) + 0.5,
        y: Double(spawnPosition.y + 1),
        z: Double(spawnPosition.z) + 0.5
    )
}
import NIOCore

class Entity {
    let world: World
    var position: Position
    let id: Int32
    lazy var dataTracker = DataTracker(entity: self)

    init(world: World, position: Position) {
        self.world = world
        self.position = position
        self.id = world.allocateEntityId()
    }
}
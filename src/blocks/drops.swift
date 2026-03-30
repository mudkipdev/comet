extension BlockLike {
    func getDroppedItemStack(heldItem: ItemStack) -> ItemStack {
        switch self.id {
        case Block.leaves.id: .air
        case Block.stone.id: .air // TODO: correct tool stuff
        case Block.grass.id: ItemStack(block: Block.dirt)
        default: ItemStack(block: self)
        }
    }
}
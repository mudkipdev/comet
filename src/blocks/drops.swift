extension Block {
    var material: Material? {
        switch self.id {
        // rock
        case Block.stone.id: .rock
        case Block.cobblestone.id: .rock
        case Block.bedrock.id: .rock
        case Block.slab.id, Block.doubleSlab.id: .rock
        case Block.sandstone.id: .rock
        case Block.lapisLazuli.id: .rock
        case Block.bricks.id: .rock
        case Block.mossyCobblestone.id: .rock
        case Block.stonePressurePlate.id: .rock
        case Block.glowstone.id: .rock
        case Block.netherrack.id: .rock
        case Block.dispenser.id: .rock
        case Block.mobSpawner.id: .rock
        case Block.furnace.id: .rock

        case Block.coalOre.id,
            Block.goldOre.id,
            Block.ironOre.id,
            Block.diamondOre.id,
            Block.lapisLazuliOre.id,
            Block.redstoneOre.id,
            Block.litRedstoneOre.id,
            Block.lapisLazuliOre.id: Material.rock

        // iron
        case Block.gold.id, Block.iron.id, Block.diamond.id: .iron
        case Block.ironDoor.id: .iron

        default: .todo
        }
    }
}

extension ToolTier {
    var harvestLevel: Int {
        switch self {
        case .wood: 0
        case .stone: 1
        case .gold: 0
        case .iron: 2
        case .diamond: 3
        }
    }
}

func canHarvestBlock(block: Block, itemStack: ItemStack) -> Bool {
    let type = ToolType.from(item: itemStack.item)
    let tier = ToolTier.from(item: itemStack.item)

    if block.id == Block.obsidian.id {
        return type == .pickaxe && tier!.harvestLevel == 3
    } else if block.id == Block.diamond.id || block.id == Block.diamondOre.id {
        return type == .pickaxe && tier!.harvestLevel >= 2
    } else if block.id == Block.gold.id || block.id == Block.goldOre.id {
        return type == .pickaxe && tier!.harvestLevel >= 2
    } else if block.id == Block.iron.id || block.id == Block.ironOre.id {
        return type == .pickaxe && tier!.harvestLevel >= 1
    } else if block.id == Block.lapisLazuli.id || block.id == Block.lapisLazuliOre.id {
        return type == .pickaxe && tier!.harvestLevel >= 1
    } else if block.id == Block.redstoneOre.id || block.id == Block.litRedstoneOre.id {
        return type == .pickaxe && tier!.harvestLevel >= 2
    } else if block.material == .rock || block.material == .iron {
        return type == .pickaxe
    }

    // TODO
    return true
}

extension BlockLike {
    func getDroppedItemStack(heldItem: ItemStack) -> ItemStack {
        if !canHarvestBlock(block: self.asBlock(), itemStack: heldItem) {
            return .air
        }

        return switch self.id {
        case Block.leaves.id: .air
        case Block.grass.id: ItemStack(block: Block.dirt)
        default: ItemStack(block: self)
        }
    }
}
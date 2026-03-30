import Testing
@testable import comet

struct TestCase {
    let block: Block
    let heldItem: ItemStack
    let expectedDrop: ItemStack

    init(block: Block, heldItem: ItemStack, expectedDrop: ItemStack) {
        self.block = block
        self.heldItem = heldItem
        self.expectedDrop = expectedDrop
    }

    init(block: Block, heldItem: Item, expectedDrop: Item) {
        self.block = block
        self.heldItem = ItemStack(item: heldItem)
        self.expectedDrop = ItemStack(item: expectedDrop)
    }

    init(block: Block, heldItem: Item, expectedDropBlock: Block) {
        self.block = block
        self.heldItem = ItemStack(item: heldItem)
        self.expectedDrop = ItemStack(block: expectedDropBlock)
    }
}

private let testCases: [TestCase] = [
    // dirt/sand/gravel — no tool requirement
    TestCase(block: .dirt, heldItem: .woodenShovel, expectedDropBlock: .dirt),
    TestCase(block: .sand, heldItem: .woodenShovel, expectedDropBlock: .sand),
    TestCase(block: .gravel, heldItem: .woodenShovel, expectedDropBlock: .gravel),

    // grass → dirt
    TestCase(block: .grass, heldItem: .woodenShovel, expectedDropBlock: .dirt),

    // leaves → nothing
    TestCase(block: Block.leaves.asBlock(), heldItem: .woodenAxe, expectedDrop: .air),

    // rock blocks — any pickaxe suffices
    TestCase(block: .stone, heldItem: .woodenPickaxe, expectedDropBlock: .stone),
    TestCase(block: .cobblestone, heldItem: .woodenPickaxe, expectedDropBlock: .cobblestone),
    TestCase(block: .sandstone, heldItem: .woodenPickaxe, expectedDropBlock: .sandstone),
    TestCase(block: .bricks, heldItem: .woodenPickaxe, expectedDropBlock: .bricks),
    TestCase(block: .mossyCobblestone, heldItem: .woodenPickaxe, expectedDropBlock: .mossyCobblestone),
    TestCase(block: .netherrack, heldItem: .woodenPickaxe, expectedDropBlock: .netherrack),

    // rock blocks — wrong tool → nothing
    TestCase(block: .stone, heldItem: .woodenShovel, expectedDrop: .air),
    TestCase(block: .stone, heldItem: .woodenAxe, expectedDrop: .air),
    TestCase(block: .cobblestone, heldItem: .woodenShovel, expectedDrop: .air),
    TestCase(block: .netherrack, heldItem: .woodenShovel, expectedDrop: .air),

    // ores requiring stone pickaxe (tier >= 1)
    TestCase(block: .ironOre, heldItem: .stonePickaxe, expectedDropBlock: .ironOre),
    TestCase(block: .lapisLazuliOre, heldItem: .stonePickaxe, expectedDropBlock: .lapisLazuliOre),
    TestCase(block: .lapisLazuli, heldItem: .stonePickaxe, expectedDropBlock: .lapisLazuli),
    TestCase(block: .ironOre, heldItem: .woodenPickaxe, expectedDrop: .air),
    TestCase(block: .lapisLazuliOre, heldItem: .woodenPickaxe, expectedDrop: .air),

    // ores requiring iron pickaxe (tier >= 2)
    TestCase(block: .goldOre, heldItem: .ironPickaxe, expectedDropBlock: .goldOre),
    TestCase(block: .gold, heldItem: .ironPickaxe, expectedDropBlock: .gold),
    TestCase(block: .diamondOre, heldItem: .ironPickaxe, expectedDropBlock: .diamondOre),
    TestCase(block: .diamond, heldItem: .ironPickaxe, expectedDropBlock: .diamond),
    TestCase(block: .redstoneOre, heldItem: .ironPickaxe, expectedDropBlock: .redstoneOre),
    TestCase(block: .litRedstoneOre, heldItem: .ironPickaxe, expectedDropBlock: .litRedstoneOre),
    TestCase(block: .goldOre, heldItem: .stonePickaxe, expectedDrop: .air),
    TestCase(block: .diamondOre, heldItem: .stonePickaxe, expectedDrop: .air),
    TestCase(block: .redstoneOre, heldItem: .stonePickaxe, expectedDrop: .air),

    // obsidian requiring diamond pickaxe (tier == 3)
    TestCase(block: .obsidian, heldItem: .diamondPickaxe, expectedDropBlock: .obsidian),
    TestCase(block: .obsidian, heldItem: .ironPickaxe, expectedDrop: .air),
    TestCase(block: .obsidian, heldItem: .stonePickaxe, expectedDrop: .air),

    // coal ore should drop coal item, not the ore block (unimplemented)
    // TestCase(block: .coalOre, heldItem: .woodenPickaxe, expectedDrop: .coal),

    // glowstone should drop glowstone dust, not the block (unimplemented)
    // TestCase(block: .glowstone, heldItem: .woodenPickaxe, expectedDrop: .glowstoneDust),
]

@Test(arguments: testCases)
func testBlockDrops(_ testCase: TestCase) {
    let actualDrop = testCase.block.getDroppedItemStack(heldItem: testCase.heldItem).item
    let expectedDrop = testCase.expectedDrop.item
    #expect(actualDrop == expectedDrop)
}

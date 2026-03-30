import NIOCore

struct Item: RawRepresentable, Equatable {
    let rawValue: Int16
    var maxStackSize: Int8 { 64 }

    static let air = Item(rawValue: -1)
    // TODO: add more items
}


struct ItemStack {
    static let air = ItemStack(item: .air)

    var item: Item
    var amount: Int8 = 1
    var metadata: Int16 = 0

    var id: Int16 {
        item.rawValue
    }

    var empty: Bool {
        item == .air || amount <= 0
    }

    init(item: Item, amount: Int8 = 1, metadata: Int16 = 0) {
        self.item = item
        self.amount = amount
        self.metadata = metadata
    }

    init(block: BlockLike, amount: Int8 = 1) {
        let blockState = block.asBlock()
        self.init(item: Item(rawValue: Int16(blockState.id)), amount: amount, metadata: Int16(blockState.data))
    }

    init(from buffer: inout ByteBuffer) throws {
        let id: Int16 = try buffer.readInteger()

        if id <= 0 {
            item = .air
            return
        }

        item = Item(rawValue: id)
        amount = try buffer.readInteger()
        metadata = try buffer.readInteger()
    }

    func write(to buffer: inout ByteBuffer) {
        buffer.writeInteger(item.rawValue)

        if item != .air {
            buffer.writeInteger(amount)
            buffer.writeInteger(metadata)
        }
    }

    func withAmount(_ amount: Int8) -> Self {
        if amount < 1 {
            return .air
        }

        return Self(item: item, amount: amount, metadata: metadata)
    }
}

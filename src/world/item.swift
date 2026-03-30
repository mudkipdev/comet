import NIOCore

enum Item: Int16 {
    case air = 0
}

struct ItemStack {
    var id: Int16
    var item: Item
    var amount: Int8 = 1
    var metadata: Int16 = 0

    init(from buffer: inout ByteBuffer) throws {
        id = try buffer.readInteger()
        item = Item(rawValue: id) ?? .air

        if id > 0 {
            amount = try buffer.readInteger()
            metadata = try buffer.readInteger()
        }
    }

    func write(to buffer: inout ByteBuffer) {
        buffer.writeInteger(item.rawValue)

        if item != .air {
            buffer.writeInteger(amount)
            buffer.writeInteger(metadata)
        }
    }
}

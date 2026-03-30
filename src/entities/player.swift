import NIOCore

class Player: Entity, PacketReceiver {
    let username: String
    var ready: Bool = false

    var heldItemSlot = 0
    let inventory = Container(size: 45)

    private let channel: Channel?

    var sneaking: Bool = false {
        didSet {
            dataTracker.set(id: 0, .byte(sneaking ? 0x02 : 0x00))
        }
    }

    var heldItem: ItemStack {
        get {
            inventory.getItemStack(slot: heldItemSlot)
        }

        set {
            inventory.setItemStack(slot: heldItemSlot, newValue)
        }
    }

    init(channel: Channel? = nil, world: World, position: Position, username: String) {
        self.channel = channel
        self.username = username
        super.init(world: world, position: position)

        inventory.subscribe(
            onSetItemStack: { [weak self] slot, itemStack in
                guard let self else {
                    return
                }

                try? sendPacket(SetSlot(
                    windowId: 0,
                    slot: convertSlotToNetwork(Int16(slot)),
                    itemStack: itemStack
                ))
            },

            onFillContainer: { [weak self] items in
                guard let self else {
                    return
                }

                let reorderedItems = (0..<items.count).map { networkSlot -> ItemStack in
                    let slot = Int(convertSlotFromNetwork(Int16(networkSlot)))

                    guard slot >= 0 && slot < items.count else {
                        return .air
                    }

                    return items[slot]
                }

                try? sendPacket(FillContainer(windowId: 0, items: reorderedItems))
            }
        )
    }

    func sendPacket(_ packet: OutgoingPacket) throws {
        guard let channel else {
            return
        }

        // TODO: improve this
        if packet is OutgoingLogin {
            ready = true
        } else if !(packet is OutgoingPreLogin || packet is OutgoingLogin) && !ready {
            return
        }

        var buffer = ByteBuffer()
        buffer.writeInteger(type(of: packet).id)
        try packet.write(to: &buffer)
        channel.writeAndFlush(buffer, promise: nil)
    }

    private func convertSlotToNetwork(_ slot: Int16) -> Int16 {
        switch slot {
        case 103: 5 // helmet
        case 102: 6 // chestplate
        case 101: 7 // leggings
        case 100: 8 // boots
        case 0..<9: slot + 36
        default: slot
        }
    }

    private func convertSlotFromNetwork(_ slot: Int16) -> Int16 {
        switch slot {
        case 0, 1, 2, 3, 4: -1 // crafting grid slots, not possible I guess
        case 5: 103 // helmet
        case 6: 102 // chestplate
        case 7: 101 // leggings
        case 8: 100 // boots
        case 36..<45: slot - 36
        default: slot
        }
    }
}
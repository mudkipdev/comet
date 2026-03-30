private struct ContainerSubscriber {
    let onSetItemStack: (Int, ItemStack) -> Void
    let onFillContainer: ([ItemStack]) -> Void
}

class Container {
    private var itemStacks: [ItemStack]
    private var subscribers: [ContainerSubscriber] = []

    init(size: Int) {
        itemStacks = Array(repeating: ItemStack.air, count: size)
    }

    var size: Int {
        itemStacks.count
    }

    var empty: Bool {
        itemStacks.allSatisfy { $0.empty }
    }

    func getItemStack(slot: Int) -> ItemStack {
        itemStacks[slot]
    }

    func setItemStack(slot: Int, _ itemStack: ItemStack) {
        itemStacks[slot] = itemStack

        for subscriber in subscribers {
            subscriber.onSetItemStack(slot, itemStack)
        }
    }

    func addItemStack(_ newItemStack: ItemStack) {
        if newItemStack.empty {
            return
        }

        for slot in 0..<size {
            let itemStack = getItemStack(slot: slot)
            let item = itemStack.item

            if itemStack.amount == item.maxStackSize {
                continue
            }

            if item == newItemStack.item {
                let summedAmount = Int16(itemStack.amount) + Int16(newItemStack.amount)

                if summedAmount > Int16(item.maxStackSize) {
                    setItemStack(slot: slot, ItemStack(item: item, amount: item.maxStackSize))
                    addItemStack(ItemStack(item: item, amount: Int8(summedAmount - Int16(item.maxStackSize))))
                } else {
                    setItemStack(slot: slot, ItemStack(item: item, amount: Int8(summedAmount)))
                }

                return
            } else if itemStack.empty {
                setItemStack(slot: slot, newItemStack)
                return
            }
        }
    }

    func clear() {
        for slot in 0..<size {
            setItemStack(slot: slot, .air)
        }
    }

    func subscribe(
        onSetItemStack: @escaping (Int, ItemStack) -> Void,
        onFillContainer: @escaping ([ItemStack]) -> Void
    ) {
        let subscriber = ContainerSubscriber(onSetItemStack: onSetItemStack, onFillContainer: onFillContainer)
        subscribers.append(subscriber)
        subscriber.onFillContainer(itemStacks)
    }
}
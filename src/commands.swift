enum CommandError: Error {
    case invalidSyntax
    case unknownCommand
    case noPermission
}

protocol Command {
    static var name: String { get }
    static var usage: String { get }
    static var description: String { get }

    static func hasPermission(player: Player) -> Bool
    static func execute(player: Player, arguments: [String]) throws
}

extension Command {
    static func hasPermission(player: Player) -> Bool { true }
}

struct CommandRegistry {
    private var _commands: [String: any Command.Type] = [:]

    var commands: [any Command.Type] {
        _commands.values.sorted { $0.name < $1.name }
    }

    mutating func register<C: Command>(_ type: C.Type) {
        _commands[C.name] = type
    }

    func dispatch(player: Player, input: String) throws {
        var parts = input.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        guard let name = parts.first else { return }
        parts.removeFirst()

        guard let type = _commands[name] else {
            throw CommandError.unknownCommand
        }

        guard type.hasPermission(player: player) else {
            throw CommandError.noPermission
        }

        try type.execute(player: player, arguments: parts)
    }
}

enum ClearCommand: Command {
    static let name = "clear"
    static let usage = "/clear"
    static let description = "Clear your inventory"

    static func execute(player: Player, arguments: [String]) throws {
        guard arguments.isEmpty else {
            throw CommandError.invalidSyntax
        }

        player.inventory.clear()
    }
}

enum GiveCommand: Command {
    static let name = "give"
    static let usage = "/give <id> [amount]"
    static let description = "Give yourself an item"

    static func execute(player: Player, arguments: [String]) throws {
        guard arguments.count == 1 || arguments.count == 2 else {
            throw CommandError.invalidSyntax
        }

        let idParts = arguments[0].split(separator: ":", maxSplits: 1)

        guard let id = Int16(idParts[0]) else {
            throw CommandError.invalidSyntax
        }

        let metadata = idParts.count == 2 ? Int16(idParts[1]) : nil
        let amount = arguments.count == 2 ? Int8(arguments[1]) : nil

        player.inventory.addItemStack(ItemStack(
            id: id,
            amount: amount ?? 1,
            metadata: metadata ?? 0
        ))
    }
}

enum HelpCommand: Command {
    static let name = "help"
    static let usage = "/help"
    static let description = "List all commands"

    static func execute(player: Player, arguments: [String]) throws {
        guard arguments.isEmpty else {
            throw CommandError.invalidSyntax
        }

        let commandRegistry = player.world.server.commandRegistry
        player.sendMessage("")

        for command in commandRegistry.commands {
            player.sendMessage("  \(ChatColor.white)/\(command.name) \(ChatColor.gray)\(command.description)")
        }

        player.sendMessage("")
    }
}
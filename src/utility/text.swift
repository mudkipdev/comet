enum ChatColor: String, CustomStringConvertible {
    case black = "§0"
    case darkBlue = "§1"
    case darkGreen = "§2"
    case darkAqua = "§3"
    case darkRed = "§4"
    case darkPurple = "§5"
    case gold = "§6"
    case gray = "§7"
    case darkGray = "§8"
    case blue = "§9"
    case green = "§a"
    case aqua = "§b"
    case red = "§c"
    case lightPurple = "§d"
    case yellow = "§e"
    case white = "§f"

    var description: String {
        rawValue
    }

    static func + (left: ChatColor, right: String) -> String {
        left.rawValue + right
    }

    static func + (left: String, right: ChatColor) -> String {
        left + right.rawValue
    }
}
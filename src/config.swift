import Foundation

struct Config: Codable {
    var port: UInt16 = 25565
    var admins: [String] = []
}

func loadConfig() throws -> Config {
    let url = URL(fileURLWithPath: "config.json")

    if let data = try? Data(contentsOf: url), let config = try? JSONDecoder().decode(Config.self, from: data) {
        return config
    }

    let config = Config()
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted]

    if var json = String(data: try encoder.encode(config), encoding: .utf8) {
        json = json.replacingOccurrences(of: "  ", with: "    ")
        json = json.replacingOccurrences(of: " : ", with: ": ")
        json = json.replacingOccurrences(of: #"\[\s*\]"#, with: "[]", options: .regularExpression)
        try json.write(to: url, atomically: true, encoding: .utf8)
    }

    return config
}
import Foundation

enum Secrets {
    static var openAIAPIKey: String {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
            let key = plist["OPENAI_API_KEY"] as? String
        else {
            fatalError("OPENAI_API_KEY not found in Secrets.plist")
        }
        return key
    }
} 
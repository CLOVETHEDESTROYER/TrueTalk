import Foundation
import Supabase

enum SupabaseManager {
    static let client: SupabaseClient = {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
            let supabaseUrl = plist["SUPABASE_URL"] as? String,
            let supabaseAnonKey = plist["SUPABASE_ANON_KEY"] as? String
        else {
            fatalError("Supabase credentials not found in Secrets.plist")
        }
        return SupabaseClient(supabaseURL: URL(string: supabaseUrl)!, supabaseKey: supabaseAnonKey)
    }()
} 
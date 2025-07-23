import Foundation

struct Constants {
    
    // MARK: - App Configuration
    struct App {
        static let name = "TrueTalk"
        static let version = "1.0.0"
        static let bundleIdentifier = "com.truetalk.ios"
    }
    
    // MARK: - API Configuration
    struct API {
        static let baseURL = "https://api.truetalk.com"
        static let version = "v1"
        static let timeout: TimeInterval = 30.0
        
        struct Endpoints {
            static let advice = "/advice"
            static let questions = "/questions"
            static let confessions = "/confessions"
            static let users = "/users"
            static let auth = "/auth"
        }
    }
    
    // MARK: - UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
        
        struct AnimationDurations {
            static let short: Double = 0.2
            static let medium: Double = 0.3
            static let long: Double = 0.5
        }
    }
    
    // MARK: - Content Limits
    struct ContentLimits {
        static let maxAdviceTitle = 100
        static let maxAdviceContent = 2000
        static let maxQuestionContent = 1000
        static let maxConfessionContent = 500
        static let maxCommentContent = 200
        static let maxBioLength = 150
        static let maxDisplayNameLength = 30
    }
    
    // MARK: - UserDefaults Keys
    struct UserDefaultsKeys {
        static let isFirstLaunch = "isFirstLaunch"
        static let userToken = "userToken"
        static let userId = "userId"
        static let notificationsEnabled = "notificationsEnabled"
        static let darkModeEnabled = "darkModeEnabled"
    }
    
    // MARK: - Notification Names
    struct NotificationNames {
        static let userDidSignIn = Notification.Name("userDidSignIn")
        static let userDidSignOut = Notification.Name("userDidSignOut")
        static let adviceDidUpdate = Notification.Name("adviceDidUpdate")
        static let questionDidUpdate = Notification.Name("questionDidUpdate")
        static let confessionDidUpdate = Notification.Name("confessionDidUpdate")
    }
    
    // MARK: - SF Symbols
    struct SFSymbols {
        static let advice = "heart.text.square"
        static let ask = "questionmark.circle"
        static let confessions = "lock.heart"
        static let profile = "person.circle"
        static let like = "heart"
        static let liked = "heart.fill"
        static let comment = "bubble.left"
        static let share = "square.and.arrow.up"
        static let settings = "gear"
        static let edit = "pencil"
        static let delete = "trash"
        static let report = "exclamationmark.triangle"
        static let search = "magnifyingglass"
        static let filter = "line.3.horizontal.decrease.circle"
    }
    
    // MARK: - Sample Data (for development)
    struct SampleData {
        static let sampleAdviceTitle = "How to Stay Motivated"
        static let sampleAdviceContent = "Setting small, achievable goals can help maintain motivation over time. Celebrate small wins and remember that progress, not perfection, is the goal."
        
        static let sampleQuestion = "How do I overcome procrastination when working from home?"
        
        static let sampleConfession = "I've been struggling with anxiety lately, but I'm grateful for the support of my friends and family."
        
        static let sampleUserBio = "Sharing wisdom and seeking guidance in this journey called life."
    }
} 
import Foundation

public enum Emotion: String, Codable, CaseIterable, Sendable {
    case happy
    case sad
    case anxious
    case calm
    case angry
    case grateful
    case excited
    case tired
    case stressed
    case hopeful
    case neutral
    case lonely
    case proud
    case fearful
    case content
}

public extension Emotion {
    var displayName: String {
        switch self {
        case .happy: return "Happy"
        case .sad: return "Sad"
        case .anxious: return "Anxious"
        case .calm: return "Calm"
        case .angry: return "Angry"
        case .grateful: return "Grateful"
        case .excited: return "Excited"
        case .tired: return "Tired"
        case .stressed: return "Stressed"
        case .hopeful: return "Hopeful"
        case .neutral: return "Neutral"
        case .lonely: return "Lonely"
        case .proud: return "Proud"
        case .fearful: return "Fearful"
        case .content: return "Content"
        }
    }

    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .anxious: return "😰"
        case .calm: return "😌"
        case .angry: return "😠"
        case .grateful: return "🙏"
        case .excited: return "🤩"
        case .tired: return "😴"
        case .stressed: return "😤"
        case .hopeful: return "🌟"
        case .neutral: return "😐"
        case .lonely: return "🫂"
        case .proud: return "💪"
        case .fearful: return "😨"
        case .content: return "☺️"
        }
    }
}

import Foundation

/// A collection of vibes for your notifications.
/// No boring "Time to do X". We want emotional damage or dopamine. ⚡️
struct NotificationMessages {
    static let standardPool = [
        "It’s giving productive. Do the thing. ✨",
        "Manifesting this habit for you.",
        "Don't let the capitalism win. Take care of yourself.",
        "Vibe check: You haven't done this yet.",
        "Be the main character of your life today.",
        "Touch grass? Maybe later. Do this first.",
        "Consistency is your love language.",
        "POV: You just crushed your habit.",
        "Sending positive energy (and a reminder).",
        "Not to be toxic, but do you want to keep that streak?"
    ]
    
    static func randomVibe() -> String {
        standardPool.randomElement() ?? "Do the thing."
    }
}

import SwiftUI
import SwiftData

@main
struct VoidApp: App {
    // Initialize the SwiftData container for the Habit model
    let container: ModelContainer
    
    init() {
        do {
            // ✨ Schema Update: Include HabitReminder
            let schema = Schema([
                Habit.self,
                HabitReminder.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // ✨ Ask for permission nicely
            NotificationManager.shared.requestAuthorization()
            
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainDashboardView()
        }
        .modelContainer(container) // Inject the database into the app
    }
}

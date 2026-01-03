import SwiftUI
import Combine
import SwiftData

/// The central brain managing data flow between SwiftData and the View.
/// Handles fetching, updating, and logic calculations (MVVM Style).
class HabitListViewModel: ObservableObject {
    // MARK: - Properties
    
    // The ModelContext is our connection to the database
    private var modelContext: ModelContext?
    
    @Published var habits: [Habit] = []
    @Published var heatmapData: [Double] = []
    @Published var selectedRoutineTime: RoutineTime = .morning
    
    // MARK: - Computed Properties
    
    var categories: [String] {
        let allCategories = Set(habits.map { $0.category })
        return ["All"] + Array(allCategories).sorted()
    }

    // MARK: - Initialization
    
    init() {
        // Heatmap initialization (empty state)
        self.heatmapData = Array(repeating: 0.0, count: 200)
        determineCurrentRoutineTime()
    }
    
    /// Sets the context and fetches initial data. Call this from .onAppear.
    func setContext(_ context: ModelContext) {
        self.modelContext = context
        fetchHabits()
    }
    
    // MARK: - Data Fetching
    
    /// Fetches all habits from the database and updates the UI.
    func fetchHabits() {
        guard let context = modelContext else { return }
        
        do {
            // Sort by the user-defined sortOrder
            let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.sortOrder)])
            self.habits = try context.fetch(descriptor)
            
            // If empty (first launch), create samples
            if habits.isEmpty {
                createSampleHabits()
            } else {
                calculateTodayScore()
            }
        } catch {
            print("Failed to fetch habits: \(error)")
        }
    }
    
    // MARK: - Filtering Logic
    
    func habits(for category: String) -> [Habit] {
        let filtered: [Habit]
        if category == "All" {
            filtered = habits.filter { $0.routineTime == selectedRoutineTime }
        } else {
            filtered = habits.filter { $0.category == category }
        }
        return filtered.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    // MARK: - CRUD Actions (Create, Read, Update, Delete)
    
    func addHabit(title: String, emoji: String, type: HabitType, goal: Double, unit: String, recurrence: HabitRecurrence, days: Set<Int>, category: String, routineTime: RoutineTime) {
        guard let context = modelContext else { return }
        
        let maxOrder = habits.map { $0.sortOrder }.max() ?? 0
        let newHabit = Habit(
            title: title,
            emoji: emoji,
            type: type,
            currentValue: 0,
            goalValue: goal,
            unit: unit,
            recurrence: recurrence,
            frequency: Array(days), // Convert Set to Array
            category: category,
            routineTime: routineTime,
            sortOrder: maxOrder + 1
        )
        
        context.insert(newHabit)
        saveContext()
        fetchHabits()
    }
    
    /// Directly updates the object. Since Habit is now a class, reference logic applies.
    func updateHabitProgress(for habit: Habit, value: Double) {
        habit.currentValue = value
        saveContext()
        calculateTodayScore()
    }
    
    func logProgress(for habit: Habit, value: Double) {
        habit.currentValue += value
        saveContext()
        calculateTodayScore()
    }
    
    func updateHabit(_ updatedHabit: Habit) {
        // With classes, 'updatedHabit' is likely the same reference.
        // If coming from a struct-based form, ensuring persistence is key.
        // Since we bind directly to the object in SwiftData, explicit update might just need a save.
        saveContext()
        fetchHabits()
    }
    
    func deleteHabit(_ habit: Habit) {
        guard let context = modelContext else { return }
        context.delete(habit)
        saveContext()
        fetchHabits()
    }
    
    func moveHabit(from sourceID: UUID, to destinationID: UUID) {
        guard let fromIndex = habits.firstIndex(where: { $0.id == sourceID }),
              let toIndex = habits.firstIndex(where: { $0.id == destinationID }) else { return }
        
        let movedHabit = habits.remove(at: fromIndex)
        habits.insert(movedHabit, at: toIndex)

        // Update sortOrder for persistence
        for (index, habit) in habits.enumerated() {
            habit.sortOrder = index
        }
        saveContext()
    }
    
    private func saveContext() {
        guard let context = modelContext else { return }
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // MARK: - Internal Calculations
    
    func determineCurrentRoutineTime() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 5 && hour < 11 { selectedRoutineTime = .morning }
        else if hour >= 11 && hour < 18 { selectedRoutineTime = .day }
        else { selectedRoutineTime = .evening }
    }
    
    func calculateTodayScore() {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let adjustedWeekday = (weekday == 1) ? 7 : (weekday - 1)
        
        let activeHabits = habits.filter { habit in
            switch habit.recurrence {
            case .daily: return true
            case .weekly: return habit.frequency.contains(adjustedWeekday)
            case .monthly: return true
            }
        }
        
        if activeHabits.isEmpty {
            updateHeatmap(0.0)
            return
        }
        
        let completedCount = activeHabits.filter { $0.currentValue >= $0.goalValue }.count
        let score = Double(completedCount) / Double(activeHabits.count)
        updateHeatmap(score)
    }
    
    private func updateHeatmap(_ score: Double) {
        if !heatmapData.isEmpty {
            heatmapData[heatmapData.count - 1] = score
        }
    }

    // MARK: - Sample Data
    
    private func createSampleHabits() {
        guard let context = modelContext else { return }
        
        let samples = [
            Habit(title: "Drink Water", emoji: "💧", type: .value, goalValue: 8, unit: "Glasses", category: "Health", routineTime: .morning, sortOrder: 0),
            Habit(title: "Make Bed", emoji: "🛏️", type: .checkmark, goalValue: 1, unit: "", category: "Mindset", routineTime: .morning, sortOrder: 1),
            Habit(title: "Walk", emoji: "🚶", type: .value, goalValue: 30, unit: "Min", category: "Health", routineTime: .day, sortOrder: 2),
            Habit(title: "Deep Work", emoji: "💻", type: .value, goalValue: 2, unit: "Sessions", category: "Mindset", routineTime: .day, sortOrder: 3),
            Habit(title: "Read", emoji: "📖", type: .value, goalValue: 10, unit: "Pages", category: "Mindset", routineTime: .evening, sortOrder: 4),
            Habit(title: "No Phone", emoji: "📵", type: .checkmark, goalValue: 1, unit: "", category: "Health", routineTime: .evening, sortOrder: 5)
        ]
        
        for sample in samples {
            context.insert(sample)
        }
        saveContext()
        fetchHabits()
    }
}

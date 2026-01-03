import SwiftUI
import Combine

/// The central state manager for all habit-related data and logic.
/// It acts as the "Single Source of Truth" for the entire app.
class HabitListViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var habits: [Habit] = []
    @Published var heatmapData: [Double] = []
    @Published var selectedRoutineTime: RoutineTime = .morning
    
    // MARK: - Computed Properties
    
    /// Returns a sorted list of all unique categories used by the user.
    var categories: [String] {
        let allCategories = Set(habits.map { $0.category })
        return ["All"] + Array(allCategories).sorted()
    }

    // MARK: - Initialization
    
    init() {
        // Initialize heatmap with 200 empty days
        self.heatmapData = Array(repeating: 0.0, count: 200)
        determineCurrentRoutineTime()
        
        // Load some initial data if the list is empty
        if habits.isEmpty {
            createSampleHabits()
        }
    }
    
    // MARK: - Filtering Logic
    
    /// Returns habits filtered by category and the currently selected routine time.
    /// - Parameter category: The category to filter by (e.g., "Health" or "All").
    func habits(for category: String) -> [Habit] {
        let filtered: [Habit]
        if category == "All" {
            // Filter by time of day (Morning/Day/Evening)
            filtered = habits.filter { $0.routineTime == selectedRoutineTime }
        } else {
            // Filter by specific user category
            filtered = habits.filter { $0.category == category }
        }
        // Always return sorted by the user's custom order
        return filtered.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    // MARK: - Habit Actions
    
    /// Moves a habit from one position to another (Drag & Drop support).
    func moveHabit(from sourceID: UUID, to destinationID: UUID) {
        guard let fromIndex = habits.firstIndex(where: { $0.id == sourceID }),
              let toIndex = habits.firstIndex(where: { $0.id == destinationID }) else { return }
        
        let movedHabit = habits.remove(at: fromIndex)
        habits.insert(movedHabit, at: toIndex)

        // Re-index the sort order for all habits to persist the new order
        for (index, _) in habits.enumerated() {
            habits[index].sortOrder = index
        }
    }

    /// Adds a new habit to the collection.
    func addHabit(title: String, emoji: String, type: HabitType, goal: Double, unit: String, recurrence: HabitRecurrence, days: Set<Int>, category: String, routineTime: RoutineTime) {
        let maxOrder = habits.map { $0.sortOrder }.max() ?? 0
        let newHabit = Habit(
            title: title,
            emoji: emoji,
            type: type,
            currentValue: 0,
            goalValue: goal,
            unit: unit,
            recurrence: recurrence,
            frequency: days,
            category: category,
            routineTime: routineTime,
            sortOrder: maxOrder + 1
        )
        
        DispatchQueue.main.async {
            self.habits.append(newHabit)
            self.calculateTodayScore()
        }
    }
    
    /// Updates the current value of a habit (e.g., adding +5 minutes or checking a box).
    func updateHabitProgress(for habit: Habit, value: Double) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].currentValue = value
            calculateTodayScore()
        }
    }
    
    /// Increments the current value (Helper for the LogProgressSheet).
    func logProgress(for habit: Habit, value: Double) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].currentValue += value
            calculateTodayScore()
        }
    }
    
    /// Updates all properties of an existing habit.
    func updateHabit(_ updatedHabit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == updatedHabit.id }) {
            habits[index] = updatedHabit
            calculateTodayScore()
        }
    }
    
    /// Removes a habit from the list.
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        calculateTodayScore()
    }
    
    // MARK: - Internal Calculations
    
    /// Automatically sets the routine time based on the current hour.
    func determineCurrentRoutineTime() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 5 && hour < 11 { selectedRoutineTime = .morning }
        else if hour >= 11 && hour < 18 { selectedRoutineTime = .day }
        else { selectedRoutineTime = .evening }
    }
    
    /// Calculates the completion percentage for the current day to update the Heatmap.
    func calculateTodayScore() {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        // Adjust Sunday from 1 to 7 if needed for custom logic
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
    
    /// Injects the latest score into the heatmap data array.
    private func updateHeatmap(_ score: Double) {
        if !heatmapData.isEmpty {
            heatmapData[heatmapData.count - 1] = score
        }
    }

    // MARK: - Setup
    
    /// Creates initial habits to show the user how the app works.
    private func createSampleHabits() {
        let samples = [
            Habit(title: "Drink Water", emoji: "💧", type: .value, goalValue: 8, unit: "Glasses", category: "Health", routineTime: .morning, sortOrder: 0),
            Habit(title: "Make Bed", emoji: "🛏️", type: .checkmark, goalValue: 1, unit: "", category: "Mindset", routineTime: .morning, sortOrder: 1),
            Habit(title: "Walk", emoji: "🚶", type: .value, goalValue: 30, unit: "Min", category: "Health", routineTime: .day, sortOrder: 2),
            Habit(title: "Deep Work", emoji: "💻", type: .value, goalValue: 2, unit: "Sessions", category: "Mindset", routineTime: .day, sortOrder: 3),
            Habit(title: "Read", emoji: "📖", type: .value, goalValue: 10, unit: "Pages", category: "Mindset", routineTime: .evening, sortOrder: 4),
            Habit(title: "No Phone", emoji: "📵", type: .checkmark, goalValue: 1, unit: "", category: "Health", routineTime: .evening, sortOrder: 5)
        ]
        self.habits.append(contentsOf: samples)
        calculateTodayScore()
    }
}

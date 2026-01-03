import XCTest
import SwiftData
@testable import void_ // Stelle sicher, dass dies dein Modulname ist

@MainActor
final class HabitListViewModelTests: XCTestCase {
    
    var viewModel: HabitListViewModel!
    var container: ModelContainer!
    
    override func setUpWithError() throws {
        // 🧠 In-Memory Container Setup
        // Wir wollen keine echte Datenbank vollspammen, also nutzen wir den RAM.
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema([Habit.self])
        
        container = try ModelContainer(for: schema, configurations: [config])
        
        // ViewModel initialisieren und Context injizieren
        viewModel = HabitListViewModel()
        viewModel.setContext(container.mainContext)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        container = nil
    }

    // MARK: - CRUD Tests (Create, Read, Update, Delete)
    
    func testAddHabit() {
        // Arrange: Start with zero habits
        XCTAssertTrue(viewModel.habits.isEmpty, "Start list should be empty (no cap)")
        
        // Act: Add a fresh habit
        viewModel.addHabit(
            title: "Touch Grass",
            emoji: "🌱",
            type: .checkmark,
            goal: 1.0,
            unit: "",
            recurrence: .daily,
            days: [1,2,3,4,5,6,7],
            category: "Health",
            routineTime: .day
        )
        
        // Assert: Check if it landed
        XCTAssertEqual(viewModel.habits.count, 1, "Habit count should be 1. Math ain't mathing?")
        XCTAssertEqual(viewModel.habits.first?.title, "Touch Grass", "Title mismatch. Major cringe.")
    }
    
    func testDeleteHabit() {
        // Arrange
        viewModel.addHabit(
            title: "Delete Me",
            emoji: "🗑️",
            type: .checkmark,
            goal: 1,
            unit: "",
            recurrence: .daily,
            days: [],
            category: "Test",
            routineTime: .morning
        )
        let habitToDelete = viewModel.habits.first!
        
        // Act
        viewModel.deleteHabit(habitToDelete)
        
        // Assert
        XCTAssertTrue(viewModel.habits.isEmpty, "List should be empty after delete. Ghost habit detected? 👻")
    }
    
    // MARK: - Logic Tests (The Brain)
    
    func testScoreCalculation() {
        // Arrange: Create 2 habits for today
        // 1. Water (Value Type)
        viewModel.addHabit(title: "Water", emoji: "💧", type: .value, goal: 2, unit: "L", recurrence: .daily, days: [1,2,3,4,5,6,7], category: "Health", routineTime: .morning)
        // 2. Meditate (Checkmark Type)
        viewModel.addHabit(title: "Zen", emoji: "🧘", type: .checkmark, goal: 1, unit: "", recurrence: .daily, days: [1,2,3,4,5,6,7], category: "Mindset", routineTime: .morning)
        
        let waterHabit = viewModel.habits.first { $0.title == "Water" }!
        let zenHabit = viewModel.habits.first { $0.title == "Zen" }!
        
        // Act 1: Complete 50% of total tasks (Zen done, Water 0)
        viewModel.updateHabitProgress(for: zenHabit, value: 1.0)
        
        // Assert 1
        // Score logic: 1 active completed / 2 active total = 0.5
        XCTAssertEqual(viewModel.heatmapData.last, 0.5, "Score should be 0.5 (50%). Algorithm is tripping.")
        
        // Act 2: Complete Water fully
        viewModel.updateHabitProgress(for: waterHabit, value: 2.0)
        
        // Assert 2
        // Score logic: 2/2 = 1.0
        XCTAssertEqual(viewModel.heatmapData.last, 1.0, "Score should be 1.0. Full completion not recognized.")
    }
    
    func testMoveHabitOrder() {
        // Arrange
        viewModel.addHabit(title: "First", emoji: "1️⃣", type: .checkmark, goal: 1, unit: "", recurrence: .daily, days: [], category: "Test", routineTime: .morning)
        viewModel.addHabit(title: "Second", emoji: "2️⃣", type: .checkmark, goal: 1, unit: "", recurrence: .daily, days: [], category: "Test", routineTime: .morning)
        
        let firstID = viewModel.habits[0].id
        let secondID = viewModel.habits[1].id
        
        // Act: Move first to second position
        viewModel.moveHabit(from: firstID, to: secondID)
        
        // Assert
        XCTAssertEqual(viewModel.habits[0].title, "Second", "Reorder failed. First item should be Second now.")
        XCTAssertEqual(viewModel.habits[0].sortOrder, 0, "SortOrder index 0 not updated.")
        XCTAssertEqual(viewModel.habits[1].sortOrder, 1, "SortOrder index 1 not updated.")
    }
}

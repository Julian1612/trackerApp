//
//  HabitListViewModel.swift
//  void.
//
//  Created by Julian Schneider on 02.01.26.
//

import SwiftUI
import Combine

class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var heatmapData: [Double] = []

    init() {
        setupMockData()
    }

    private func setupMockData() {
        self.heatmapData = (0..<200).map { _ in Double.random(in: 0...1) }
        // Startdaten können bleiben oder geleert werden
        self.habits = [
            Habit(title: "Eat Vege", iconName: "leaf.fill", type: .counter, currentValue: 75, goalValue: 100, displayValue: "75")
        ]
    }

    // Neue Funktion zum Hinzufügen
    func addHabit(title: String, type: HabitType, goal: Double) {
        let newHabit = Habit(
            title: title,
            iconName: type == .checkmark ? "checkmark.circle" : "timer",
            type: type,
            currentValue: 0,
            goalValue: goal,
            displayValue: type == .checkmark ? "" : "0"
        )
        habits.append(newHabit)
    }
}


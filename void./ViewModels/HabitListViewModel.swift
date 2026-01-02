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
        // Generierung von 200 Tagen Aktivität
        self.heatmapData = (0..<200).map { _ in Double.random(in: 0...1) }
        
        // Initialisierung basierend auf Referenzdesign image_10.png
        self.habits = [
            Habit(title: "Eat Vege", iconName: "leaf.fill", type: .counter, currentValue: 75, goalValue: 100, displayValue: "75"),
            Habit(title: "Sleep early 0h", iconName: "moon.stars.fill", type: .duration, currentValue: 0, goalValue: 8, displayValue: "0"),
            Habit(title: "Read 10 pages", iconName: "person.fill", type: .duration, currentValue: 4, goalValue: 10, displayValue: "0h"),
            Habit(title: "Meditate 10 pages", iconName: "person.fill", type: .duration, currentValue: 10, goalValue: 10, displayValue: "20 m"),
            Habit(title: "No social media", iconName: "display", type: .checkmark, currentValue: 1, goalValue: 1, displayValue: "✓")
        ]
    }
}

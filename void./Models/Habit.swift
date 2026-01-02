//
//  Habit.swift
//  void.
//
//  Created by Julian Schneider on 02.01.26.
//

import Foundation

enum HabitType {
    case counter     // Numerisch (z.B. Eat Vege)
    case duration    // Zeit/Fortschritt (z.B. Meditate)
    case checkmark   // Boolean (z.B. Workout)
}

struct Habit: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    let type: HabitType
    var currentValue: Double
    var goalValue: Double
    var displayValue: String // z.B. "75", "0h", "20 m", "✓"
}

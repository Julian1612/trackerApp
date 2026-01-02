//
//  HabitRowView.swift
//  void.
//
//  Created by Julian Schneider on 02.01.26.
//

import SwiftUI
struct HabitRowView: View {
    let habit: Habit

    var body: some View {
        HStack(spacing: 12) {
            HabitIconComponent(habit: habit)

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(Typography.habitTitle)
                    .foregroundColor(ColorPalette.primary)

                // Secondary status/value line
                Text(habit.displayValue)
                    .font(Typography.statusValue)
                    .foregroundColor(ColorPalette.primary.opacity(0.6))
            }
            Spacer()

            // Right aligned status for quick glance
            if habit.type == .duration {
                Text("\(Int(habit.currentValue))/\(Int(habit.goalValue))h")
                    .font(Typography.statusValue)
                    .foregroundColor(ColorPalette.primary)
            } else if habit.type == .counter {
                Text(habit.displayValue)
                    .font(Typography.statusValue)
                    .foregroundColor(ColorPalette.primary)
            } else if habit.type == .checkmark {
                Text(habit.displayValue)
                    .font(Typography.statusValue)
                    .foregroundColor(ColorPalette.primary)
            }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    List {
        HabitRowView(habit: Habit(title: "Eat Vege", iconName: "leaf.fill", type: .counter, currentValue: 75, goalValue: 100, displayValue: "75"))
        HabitRowView(habit: Habit(title: "Meditate", iconName: "person.fill", type: .duration, currentValue: 2, goalValue: 10, displayValue: "20 m"))
        HabitRowView(habit: Habit(title: "No Social", iconName: "display", type: .checkmark, currentValue: 1, goalValue: 1, displayValue: "✓"))
    }
    .listStyle(.plain)
}


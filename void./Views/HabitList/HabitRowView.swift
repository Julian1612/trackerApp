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
        HStack(spacing: 16) {
            HabitIconComponent(habit: habit)

            Text(habit.title)
                .font(Typography.habitTitle)
                .foregroundColor(ColorPalette.primary)

            Spacer()

            Text(habit.displayValue)
                .font(Typography.statusValue)
                .foregroundColor(ColorPalette.primary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}

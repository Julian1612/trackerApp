//
//  HabitIconComponent.swift
//  void.
//
//  Created by Julian Schneider on 02.01.26.
//

import SwiftUI

struct HabitIconComponent: View {
    let habit: Habit
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(ColorPalette.primary, lineWidth: 1.2) // Kreis-Umriss
            
            if habit.type == .duration {
                Circle() // Fortschritts-Ring
                    .trim(from: 0, to: habit.currentValue / habit.goalValue)
                    .stroke(ColorPalette.primary, lineWidth: 2.5)
                    .rotationEffect(.degrees(-90))
            }
            
            Image(systemName: habit.iconName)
                .font(.system(size: 14))
        }
        .frame(width: 36, height: 36)
    }
}

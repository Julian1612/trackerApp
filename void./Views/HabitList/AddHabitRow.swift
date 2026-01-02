//
//  AddHabitRow.swift
//  void.
//
//  Created by Julian Schneider on 02.01.26.
//

import SwiftUI

struct AddHabitRow: View {
    @ObservedObject var viewModel: HabitListViewModel
    @State private var title: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Ein leerer, gestrichelter Kreis als dezentes Icon
            Circle()
                .stroke(ColorPalette.primary.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [4]))
                .frame(width: 36, height: 36)
            
            TextField("New Routine...", text: $title)
                .font(Typography.habitTitle)
                .focused($isFocused)
                .onSubmit {
                    if !title.isEmpty {
                        viewModel.addHabit(title: title, icon: "checkmark.circle", type: .checkmark, goal: 1, unit: "times")
                        title = ""
                        isFocused = false
                    }
                }
            
            if isFocused {
                Button("Done") {
                    isFocused = false
                }
                .font(Typography.statusValue)
                .foregroundColor(ColorPalette.primary)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .opacity(isFocused ? 1.0 : 0.4) // Dezent im Ruhezustand
        .animation(.easeInOut, value: isFocused)
    }
}


//
//  AddHabitSheet.swift
//  void.
//
//  Created by Julian Schneider on 02.01.26.
//

import SwiftUI

struct AddHabitSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitListViewModel
    
    @State private var title = ""
    @State private var selectedType: HabitType = .checkmark
    @State private var goal = 1.0
    @State private var unit = ""
    @State private var iconName = "star.fill"

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Titel", text: $title)
                    Picker("Typ", selection: $selectedType) {
                        Text("Checkmark").tag(HabitType.checkmark)
                        Text("Zähler").tag(HabitType.counter)
                        Text("Dauer").tag(HabitType.duration)
                    }
                }
                
                Section(header: Text("Zielvorgabe")) {
                    if selectedType != .checkmark {
                        Stepper("Ziel: \(Int(goal))", value: $goal, in: 1...1000)
                        TextField("Einheit (z.B. 0h, 20m, 75)", text: $unit)
                    } else {
                        Text("Boolean Tracker (✓)")
                    }
                }
            }
            .navigationTitle("Neue Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }.foregroundColor(.black)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        let finalUnit = selectedType == .checkmark ? "✓" : unit
                        viewModel.addHabit(title: title, icon: iconName, type: selectedType, goal: goal, unit: finalUnit)
                        dismiss()
                    }
                    .foregroundColor(.black)
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

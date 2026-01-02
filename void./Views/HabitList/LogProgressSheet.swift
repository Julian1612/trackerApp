//
//  LogProgressSheet.swift
//  void.
//
//  Created by Julian Schneider on 02.01.26.
//

import SwiftUI

struct LogProgressSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitListViewModel
    let habit: Habit
    
    @State private var valueToAdd: Double = 0
    @State private var customInput: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text(habit.emoji)
                    .font(.system(size: 40))
                Text(habit.title)
                    .font(.title2)
                    .bold()
            }
            .padding(.top, 20)
            
            Divider()
            
            // Current Progress Info
            VStack(spacing: 8) {
                Text("Aktueller Stand")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(alignment: .lastTextBaseline) {
                    Text("\(Int(habit.currentValue))")
                        .font(.system(size: 34, weight: .bold))
                    Text("/ \(Int(habit.goalValue)) \(habit.unit)")
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            
            // Input Area
            VStack(spacing: 20) {
                // Slider für visuelle Typen
                if habit.goalValue <= 120 { // Slider macht nur bei kleineren Werten Sinn
                    Slider(value: $valueToAdd, in: 0...(habit.goalValue - habit.currentValue), step: 1)
                        .accentColor(.black)
                }
                
                // Direkte Eingabe & Quick Buttons
                HStack(spacing: 12) {
                    // Minus Button
                    Button(action: { if valueToAdd > 0 { valueToAdd -= 1 } }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    
                    // Das dicke Eingabefeld
                    TextField("0", value: $valueToAdd, format: .number)
                        .font(.system(size: 40, weight: .bold))
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .frame(width: 100)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    
                    // Plus Button
                    Button(action: { valueToAdd += 1 }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                }
                
                // Quick Adds (z.B. +10, +30)
                HStack {
                    Button("+10") { valueToAdd += 10 }
                    Button("+30") { valueToAdd += 30 }
                    Button("Max") { valueToAdd = (habit.goalValue - habit.currentValue) }
                }
                .font(.footnote)
                .buttonStyle(.bordered)
                .tint(.black)
            }
            .padding()
            
            Spacer()
            
            // Save Button
            Button(action: {
                viewModel.logProgress(for: habit, value: valueToAdd)
                dismiss()
            }) {
                Text("Speichern")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .presentationDetents([.medium]) // Macht es zum "Half-Sheet"
        .presentationDragIndicator(.visible)
        .onAppear {
            // Reset input beim Öffnen
            valueToAdd = 0
        }
    }
}

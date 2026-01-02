import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitListViewModel
    
    @State private var title = ""
    @State private var selectedType: HabitType = .checkmark
    @State private var goal = 1.0

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details").foregroundColor(.black)) {
                    TextField("Name der Routine", text: $title)
                    Picker("Typ", selection: $selectedType) {
                        Text("Checkmark").tag(HabitType.checkmark)
                        Text("Counter").tag(HabitType.counter)
                        Text("Dauer").tag(HabitType.duration)
                    }
                }
            }
            .navigationTitle("Neue Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") { dismiss() }.foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Hinzufügen") {
                        viewModel.addHabit(title: title, type: selectedType, goal: goal)
                        dismiss()
                    }
                    .foregroundColor(.black)
                    .disabled(title.isEmpty)
                }
            }
        }
        .accentColor(.black)
    }
}
#Preview {
    AddHabitView(viewModel: HabitListViewModel())
}


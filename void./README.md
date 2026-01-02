🌑 Void. – Technical Documentation (v1.2)

📌 Übersicht

Void. ist ein minimalistischer Habit Tracker, implementiert als reine iOS-Anwendung mit SwiftUI. Der Fokus liegt auf einer reaktiven Architektur (MVVM), sauberer Trennung von Belangen (Separation of Concerns) und nativer iOS-UX.

Diese Dokumentation richtet sich an Entwickler und beschreibt die technische Architektur, Datenmodelle und Implementierungsdetails.

🏗 Architektur & Design Pattern

Die Anwendung folgt strikt dem Model-View-ViewModel (MVVM) Pattern, um UI-Code von Business-Logik zu entkoppeln.

1. Model Layer (Models/)

Definiert die Datenstrukturen und Typen.

Struct Habit: Unveränderliche Datenstruktur (Value Type), die eine einzelne Gewohnheit repräsentiert.

Properties:

id: UUID (Eindeutige Identifikation)

type: HabitType (Enum: .checkmark, .duration, .counter)

recurrence: HabitRecurrence (Enum: .daily, .weekly, .monthly)

routineTime: RoutineTime (Enum: .morning, .day, .evening). Bestimmt die zeitliche Zuordnung.

Logic: Enthält keine Business-Logik, reine Datenhaltung.

2. ViewModel Layer (ViewModels/)

Enthält den Anwendungszustand und die Business-Logik.

Class HabitListViewModel: Fungiert als ObservableObject.

State Management:

@Published var habits: [Habit]: Array aller Habits. Änderungen triggern UI-Updates.

@Published var heatmapData: [Double]: Array (Größe 200) für die Heatmap-Visualisierung. Letzter Index repräsentiert Date().

Time-Boxing Algorithmus (determineCurrentRoutineTime):

Verwendet Calendar.current.component(.hour) zur Ermittlung der Tageszeit.

Mapping: 05:00-11:00 -> .morning, 11:00-18:00 -> .day, sonst .evening.

Heatmap Engine (calculateTodayScore):

Filtert habits basierend auf recurrence und aktuellem Wochentag.

Berechnet Ratio: completed / total.

Normalisiert Ergebnis auf 0.0 - 1.0 für die Opazitäts-Steuerung der UI.

3. View Layer (Views/)

Deklarative UI-Komponenten.

MainDashboardView: Root-View. Verwaltet Navigation und State-Injection via @StateObject.

HabitRowView: Repräsentiert ein Listenelement. Implementiert keine Gestensteuerung, sondern verlässt sich auf native List-Interaktionen.

🛠 Technische Implementierungsdetails

Heatmap Rendering (HeatmapGridView)

Die Heatmap im GitHub-Style wird über ein LazyVGrid gerendert.

Datenquelle: Ein Array von Double Werten.

Rendering: Jeder Wert wird in eine Color.opacity transformiert.

0.0: Weiß (Leer)

1.0: Schwarz (Vollständig)

Reactivity: Durch @Published im ViewModel wird das Grid bei jeder Änderung an einem Habit (incrementHabit) sofort neu berechnet und gerendert.

Interaktionsmodell & Event Handling

Um UI-Konflikte (z.B. zwischen ScrollView und Swipe-Gesten) zu vermeiden, nutzen wir ausschließlich native SwiftUI-Komponenten.

Primary Action (Tap):

Triggered viewModel.incrementHabit(habit).

Logik unterscheidet nach HabitType: Toggle für .checkmark, Inkrement für .counter/.duration.

Secondary Actions (Context Menu):

Implementiert via .contextMenu Modifier.

Aktionen:

Edit: Setzt habitToEdit State -> Sheet Presentation.

Delete: Ruft viewModel.deleteHabit auf -> Array Mutation + Animation.

Reset: Ruft viewModel.resetHabit auf -> Setzt currentValue auf 0.

📂 Projektstruktur

void.
├── Models
│   ├── Habit.swift          // Core Data Model
│   └── ActivityData.swift   // (Deprecated)
├── ViewModels
│   └── HabitListViewModel.swift // State & Logic Container
├── Views
│   ├── Main
│   │   └── MainDashboardView.swift // Root View
│   ├── HabitList
│   │   ├── HabitRowView.swift    // List Item Component
│   │   └── AddHabitSheet.swift   // Form View (Create/Edit)
│   └── Heatmap
│       ├── HeatmapGridView.swift // Grid Logic
│       └── HeatmapTile.swift     // Single Cell Component
└── Shared
    └── Styles               // Design Tokens & Typography


🚀 Roadmap & Technical Debt

1. Datenpersistenz (High Priority)

Aktuell ist der State volatil (RAM-only).

Plan: Implementierung von SwiftData oder CoreData.

Anforderung: Persistierung des habits Arrays und der historischen heatmapData.

2. History Reconstruction

Die heatmapData enthält aktuell Platzhalter-Daten für die Vergangenheit.

Plan: Berechnung der historischen Heatmap-Werte basierend auf persistierten ActivityLogs.

3. Refactoring

Entfernung von Legacy-Code in ActivityData.swift.

Unit Tests für HabitListViewModel (insb. calculateTodayScore).

Build Requirements:

iOS Deployment Target: 16.0+

Swift Version: 5.7+

Xcode: 14.0+

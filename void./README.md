📂 Projekt-Struktur: MinimalHabitTracker

Core/

MinimalHabitTrackerApp.swift: Der zentrale Einstiegspunkt der Applikation.

Models/

Habit.swift: Definiert das Datenmodell für die verschiedenen Tracker-Typen (Counter, Duration, Boolean).

ActivityData.swift: Modell für die Repräsentation der täglichen Aktivitätswerte der Heatmap.

ViewModels/

HabitListViewModel.swift: Enthält die Geschäftslogik zur Verwaltung der Habits und zur Berechnung der Heatmap-Farbstufen basierend auf dem Activity Score.

Views/

Main/

MainDashboardView.swift: Die Container-View, welche die vertikale Aufteilung (1/3 Heatmap, 2/3 Liste) implementiert.

Heatmap/

HeatmapGridView.swift: Implementierung des Gitters aus ca. 200 quadratischen Kacheln.

HeatmapTile.swift: Einzelne Kachel-Komponente mit definierten Eckenradien und Graustufen-Logik.

HabitList/

HabitRowView.swift: Standardisierte Zeilenstruktur für die Habit-Liste.

HabitIconComponent.swift: Komponente für Icons, Kreise und Fortschritts-Ringe.

Shared/

Styles/

ColorPalette.swift: Definition der monochromen Farbwerte (#000000, #FFFFFF und Graustufen).

Typography.swift: Zentralisierte Font-Konfiguration für SF Pro (Sizing und Weights).

Extensions/

View+Extensions.swift: Helper für UI-Modifikatoren, um Redundanz im View-Code zu vermeiden.

Technische Begründung dieser Struktur
Modularität: Durch die Auslagerung der HeatmapTile und HabitIconComponent wird die Wartbarkeit erhöht. Änderungen an der visuellen Darstellung des Fortschritts-Rings wirken sich nur auf eine Datei aus.

Testbarkeit: Da die Logik (z.B. die Berechnung der Graustufen für die Heatmap) im HabitListViewModel liegt, kann diese über Unit Tests verifiziert werden, ohne die UI laden zu müssen.

Wiederverwendbarkeit: Die Komponenten in Shared/Styles stellen sicher, dass Typografie und Farben über alle Ansichten hinweg konsistent bleiben, wie vom Design gefordert.

Soll ich als nächsten Schritt die technische Implementierung der ColorPalette.swift und der HabitIconComponent.swift (inklusive des Fortschritts-Rings) vorbereiten?

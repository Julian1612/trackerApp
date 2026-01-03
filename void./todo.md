### 🚀 Phase 1: Tech-Stack "Adulting" (Vorbereitung für Test-Phase)

Bevor wir Tester an Bord holen, darf die App nicht mehr das Gedächtnis eines Goldfisches haben. Aktuell ist alles im RAM. Wenn wir die App schließen, ist der Progress weg. Das ist *major cringe*.

1.  **SwiftData Integration (The Persistence Layer):**

    -   Wir müssen deine `Habit` Models von reinen Structs zu `@Model` Klassen (SwiftData) upgraden.

    -   **Why?** Damit die Daten auf dem Device bleiben. Wir wollen ja nicht, dass die User ihre Streaks verlieren, das wäre toxisch.

    -   *Task:* `HabitListViewModel` muss statt Arrays einen `ModelContext` fetchen.

2.  **Unit Tests (The Vibe Check):**

    -   Wir brauchen Tests für `calculateTodayScore`.

    -   **Why?** Wenn der Score falsch berechnet wird, brennt die Hütte. Wir schreiben Tests, um sicherzugehen, dass die Logik *bulletproof* ist.

3.  **Onboarding Experience:**

    -   Wenn ein User die App zum ersten Mal öffnet, darf er nicht ins kalte Wasser geworfen werden.

    -   *Task:* Ein kurzes, swipable Onboarding, das erklärt: "Swipe right to complete, hold to edit". Keep it short, Gen Z hat keine Aufmerksamkeitsspanne.

* * * * *

### 🎨 Phase 2: Design "Glow Up" (High-End & Innovative)

Minimalismus ist cool, aber "nur weiß" ist manchmal etwas *basic*. Wir wollen, dass die App sich anfühlt wie ein physisches Objekt, etwas Hochwertiges. Hier sind die Inputs vom Designer:

#### 1\. Fluid Typography (The "Editorial" Look) ✍️

Aktuell nutzen wir nur System Fonts. Das ist okay, aber nicht *unique*.

-   **Der Move:** Wir mischen **San Francisco** (für Lesbarkeit) mit einer **hochwertigen Serif-Font** (z.B. *New York* oder eine Custom Font) für Überschriften.

-   **Why?** Das gibt diesen "Art Gallery"-Vibe. Denk an Magazin-Layouts, nicht an Excel-Tabellen.

-   *Implementation:* In `Typography.swift` eine `serifHeader` Font definieren.

#### 2\. Micro-Interactions & Haptics (The "Feel") 📳

Eine App muss man *fühlen*.

-   **Interactive Heatmap:** Wenn man auf ein Tile in der Heatmap tippt, sollte es nicht tot sein. Es sollte kurz *bouncen* (Scale Effect) und vielleicht ein kleines Overlay zeigen: "12. Jan: 80%".

-   **Sensory Feedback:** Wenn man einen Habit completet (Swipe), brauchen wir Partikel-Effekte. Aber bitte kein billiges Konfetti. Denk an subtile, monochrome Funken oder einen "Ripple"-Effekt, der über den Screen fließt. Das muss *satisfying* sein.

#### 3\. Dynamic Island & Live Activities 🏝️

Wir müssen dahin, wo die User sind: Auf den Lockscreen.

-   **Feature:** Wenn eine Routine (z.B. "Morning") aktiv ist, zeigen wir den Progress in der Dynamic Island an.

-   **Why?** Das ist *peak* iOS Integration. Es zeigt: "Wir sind keine Web-App, wir sind Native."

#### 4\. The "Void" Aesthetic (Dark Mode Mastery) 🌑

Der Name ist **Void**. Wir brauchen einen Dark Mode, der nicht einfach nur Grau ist.

-   **True Black (OLED):** Im Dark Mode muss der Hintergrund `#000000` sein.

-   **Glow Effects:** Die Heatmap-Tiles könnten im Dark Mode leicht "glühen" (Shadows mit der Farbe des Tiles). Das sieht auf OLED Screens absolut *wild* aus.

#### 5\. Empty States with Personality 👻

Wenn die Liste leer ist, darf da nicht einfach "Keine Habits" stehen.

-   **Idea:** Ein minimalistisches ASCII-Art oder eine abstrakte geometrische Form, die atmet (Animation). Text: "The canvas is empty. Paint your day." -- Ein bisschen poetisch, du weißt schon.

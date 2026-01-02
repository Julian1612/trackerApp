🌑 Void. -- Technical Documentation (v1.2)
=========================================

📌 Overview
-----------

**Void.** is a minimalist habit tracker, engineered as a purely native iOS application using **SwiftUI**. The project prioritizes a reactive architecture (**MVVM**), clean separation of concerns, and an intuitive, native user experience (UX) that integrates seamlessly into the iOS ecosystem.

This documentation is designed for developers and provides a deep dive into the technical architecture, data models, and specific implementation details of core features. The goal is to facilitate maintenance, scalability, and onboarding for new contributors in an open-source environment.

🏗 Architecture & Design Patterns
---------------------------------

The application strictly adheres to the **Model-View-ViewModel (MVVM)** architectural pattern. This choice decouples the UI code (View) from business logic and state (ViewModel), as well as data structures (Model), significantly enhancing testability, modularity, and maintainability.

### 1\. Model Layer (`Models/`)

The Model layer defines the fundamental data structures and types of the application. It contains no business rules but describes the shape of the data.

-   **Struct `Habit`**: This is an immutable data structure (Value Type) representing a single habit. It serves as the blueprint for all tracked activities.

    -   **Properties**:

        -   `id`: `UUID` (Universally Unique Identifier) -- Ensures unique identification of each habit, crucial for list rendering (`ForEach`) and persistence.

        -   `type`: `HabitType` (Enum) -- Distinguishes the tracking method:

            -   `.checkmark`: Binary tracking (Done/Not Done).

            -   `.duration`: Time duration tracking (e.g., minutes of sport).

            -   `.counter`: Quantity tracking (e.g., glasses of water).

        -   `recurrence`: `HabitRecurrence` (Enum) -- Defines the repetition interval:

            -   `.daily`: Every day.

            -   `.weekly`: On specific weekdays (supported by a `Set<Int>` for weekdays).

            -   `.monthly`: Once a month.

        -   `routineTime`: `RoutineTime` (Enum: `.morning`, `.day`, `.evening`). This attribute is critical for temporal contextualization and filtering of habits on the dashboard.

    -   **Logic**: The Model is kept "dumb". It contains no methods for data manipulation or validation to ensure data integrity.

### 2\. ViewModel Layer (`ViewModels/`)

The ViewModel is the heart of the application logic. It holds the current state of the app, processes user interactions, and prepares data for display in the View.

-   **Class `HabitListViewModel`**: This class acts as the central `ObservableObject` and "Single Source of Truth" for the habit screen.

    -   **State Management**:

        -   `@Published var habits: [Habit]`: An array storing all existing habits. Any modification to this array (add, delete, update) automatically triggers a re-render of affected Views.

        -   `@Published var heatmapData: [Double]`: A fixed-size array (200) providing data for the heatmap visualization. The last index always represents the current day (`Date()`), with preceding indices representing history.

    -   **Time-Boxing Algorithm (`determineCurrentRoutineTime`)**:

        -   An intelligent function that determines the current time of day based on `Calendar.current.component(.hour)` and sets the appropriate filter.

        -   **Mapping Rules**:

            -   05:00 AM to 10:59 AM -> `.morning`

            -   11:00 AM to 05:59 PM -> `.day`

            -   06:00 PM to 04:59 AM -> `.evening`

    -   **Heatmap Engine (`calculateTodayScore`)**:

        -   Calculates the daily progress score for the heatmap.

        -   **Process**:

            1.  **Filtering**: Only considers habits relevant for the *current* weekday or due to their interval (`recurrence`).

            2.  **Ratio Calculation**: `Count of completed habits / Total count of due habits`.

            3.  **Normalization**: The result is normalized to a Double value between `0.0` and `1.0`, directly controlling the opacity of the heatmap tile.

### 3\. View Layer (`Views/`)

The View layer consists of declarative SwiftUI components visualizing the ViewModel's state. They are purely reactive and possess no internal state not derived from the ViewModel (except for transient UI state like navigation).

-   **`MainDashboardView`**: The application's root view. Responsible for:

    -   Initializing the `HabitListViewModel` via `@StateObject`.

    -   Structuring the layout (Header with Heatmap, Toolbar, List).

    -   Coordinating sheet presentations (e.g., for creating new habits).

-   **`HabitRowView`**: Represents a single list item.

    -   **Design Decision**: Complex swipe gestures are explicitly avoided to prevent conflicts with `List` scrolling logic. The component relies on native interaction patterns like Taps and Context Menus for stability.

🛠 Technical Implementation Details
-----------------------------------

### Heatmap Rendering (`HeatmapGridView`)

The heatmap, inspired by the GitHub contribution graph, is technically implemented using a `LazyVGrid`, ensuring performant rendering even with numerous data points.

-   **Data Source**: The view consumes the `heatmapData` array (`[Double]`) from the ViewModel.

-   **Rendering Logic**: Each numeric value is dynamically transformed into a visual representation:

    -   `Color.opacity(value)`: The value between 0.0 and 1.0 directly determines color intensity.

    -   `0.0`: White (Empty/Inactive) -- rendered with a subtle border to maintain grid visibility.

    -   `1.0`: Black (Complete) -- Signals maximum productivity.

-   **Reactivity**: Thanks to the `@Published` property in the ViewModel, the grid recalculates and re-renders *immediately* upon any relevant state change (e.g., `incrementHabit`), providing real-time feedback without manual refresh.

### Interaction Model & Event Handling

To guarantee high stability and a frustration-free user experience (UX), custom gesture recognizers within scrollable lists are avoided. UI conflicts (e.g., vertical scrolling vs. horizontal swiping) are a common source of bugs in mobile apps.

-   **Primary Action (Tap)**:

    -   A simple tap on a habit's icon triggers `viewModel.incrementHabit(habit)`.

    -   **Polymorphic Logic**: The method internally differentiates by `HabitType`:

        -   `.checkmark`: Toggles status between 0 and 1.

        -   `.counter` / `.duration`: Increments value by +1 (or a defined step).

-   **Secondary Actions (Context Menu)**:

    -   For advanced options, we utilize SwiftUI's native `.contextMenu` modifier, activated by a long press.

    -   **Available Actions**:

        -   `Edit`: Sets the `habitToEdit` state, triggering the presentation of the edit sheet (`AddHabitSheet`).

        -   `Delete`: Calls `viewModel.deleteHabit`. This removes the item from the array and triggers a deletion animation in the list.

        -   `Reset`: Calls `viewModel.resetHabit`. Immediately resets the habit's `currentValue` to 0, allowing users to restart.

📂 Project Structure
--------------------

The file structure mirrors the architectural separation, facilitating project navigation.

```
void.
├── Models
│   ├── Habit.swift          // Core Data Model & Enums
│   └── ActivityData.swift   // (Deprecated/Legacy Code - slated for removal)
├── ViewModels
│   └── HabitListViewModel.swift // Central State & Logic Component
├── Views
│   ├── Main
│   │   └── MainDashboardView.swift // Root View & Navigation Entry Point
│   ├── HabitList
│   │   ├── HabitRowView.swift    // Reusable List Component
│   │   └── AddHabitSheet.swift   // Form for Creation & Editing
│   └── Heatmap
│       ├── HeatmapGridView.swift // Grid Layout & Rendering Logic
│       └── HeatmapTile.swift     // Single Tile Component
└── Shared
    └── Styles               // Global Design Tokens, Colors & Typography

```

🚀 Roadmap & Technical Debt
---------------------------

To evolve the application from a prototype to a production-ready product, the following technical debts and features must be addressed:

### 1\. Data Persistence (High Priority / Critical)

Currently, the entire application state is volatile (RAM-only). All data is lost when the app is closed.

-   **Plan**: Implement a persistence layer using **SwiftData** (preferred for iOS 17+) or **CoreData**.

-   **Requirements**:

    -   Persistence of the `habits` array including all properties.

    -   Persistence of historical `heatmapData` to store progress over days.

    -   Migration of current in-memory logic to database queries.

### 2\. History Reconstruction & Analytics

The `heatmapData` currently contains placeholder data (zeros) for the past, as no history is stored.

-   **Plan**: Introduce an `ActivityLog` entity that stores every habit completion with a timestamp.

-   **Implementation**: On app launch, the heatmap is dynamically reconstructed based on these logs ("Replaying History").

### 3\. Refactoring & Code Quality

-   **Cleanup**: Removal of legacy code in `ActivityData.swift` and unused views (e.g., old swipe logic).

-   **Testing**: Introduction of Unit Tests for `HabitListViewModel`, especially for the critical `calculateTodayScore` logic, to prevent regression bugs in future changes.

**Build Requirements:**

-   **iOS Deployment Target**: 16.0+ (Leveraging modern SwiftUI APIs)

-   **Swift Version**: 5.7+

-   **Xcode**: 14.0+

# Role: Senior iOS Developer (SwiftUI Expert)

**Task:** Create a complete SwiftUI iOS App project named "LiangLeMe".
**Context:** This is a minimalist, dark-humor app designed to track "waiting time" for replies in a relationship, helping users realize they are being ignored ("ghosted").

Please generate the code following the MVVM architecture. Use **SwiftData** for local persistence.

---

## 1. Design System & Assets
* **Theme:** Enforce `.preferredColorScheme(.dark)`.
* **Colors:**
    * `KleinBlue`: Hex #002FA7
    * `DeadGrey`: Hex #333333
    * `HopePink`: Hex #FFC0CB
* **Fonts:** Use Serif fonts (e.g., `Font.system(size: X, design: .serif)`) for all text to create a "serious obituary" vibe.

## 2. Data Model (SwiftData)
Create a model named `WaitingRecord`:
* `id`: UUID
* `startTime`: Date
* `endTime`: Date?
* `duration`: TimeInterval (Computed)
* `targetName`: String (Default "The One")

## 3. Key Views & Logic

### A. Main View: "The Morgue" (TimerView)
* **Visuals:** A full-screen view with a dynamic background color that changes based on `elapsedTime`:
    * 0-10 mins: Interpolate Black to HopePink.
    * 10 mins - 2 hours: Interpolate to KleinBlue.
    * 2 hours+: Fade to DeadGrey/Black.
* **Components:**
    * A large, central, breathing circle button.
    * Text showing current timer: `HH:MM:SS`.
    * A "Sarcastic Quote" area that updates every minute from a local array of strings (e.g., "Probably just in the shower... for 3 hours.").
* **Logic:**
    * Tap to Start: Create new `WaitingRecord`, save `startTime`.
    * Tap to Stop: Update `endTime`, save context.

### B. Stats View: "Medical Record" (StatsView)
* **Calculations:**
    * `Total Wasted Time`: Sum of all durations.
    * `Simp Index`: A calculated integer (0-100). Formula: `min(100, (averageWaitHours * 10))`.
* **List:** Use `List` to show history. If duration > 24 hours, show an icon of a "Tombstone" or "Skull".

### C. Analysis View: "Autopsy" (AnalysisView)
* **Input:** A `TextEditor` for pasting chat history.
* **Action:** A button "Analyze Cause of Death".
* **Logic (Local Mock):**
    * Count user's lines vs. input lines (simple split by newline).
    * Check for keywords: ["呵呵", "嗯", "哦", "洗澡", "忙"].
    * **Output:** Show a "Death Report" card.
        * If keywords found: Cause = "Perfunctory (敷衍死)".
        * If line count low: Cause = "Cold Violence (冷暴力)".
        * Default: "Just not into you".

## 4. Implementation Steps
Please provide the code in this order:
1.  **AppEntry**: Including SwiftData container setup.
2.  **Models**: The `WaitingRecord` class.
3.  **ViewModels**: `TimerViewModel` (handling the timer and color logic), `StatsViewModel`.
4.  **Views**: `TimerView`, `StatsView`, `AnalysisView`, and a `ContentView` holding the TabView.
5.  **Utilities**: An extension for `Color` to handle Hex and interpolation, and a `SarcasticQuotes` provider.

**Tone of Code:** Clean, functional, and strictly following the UI requirements.
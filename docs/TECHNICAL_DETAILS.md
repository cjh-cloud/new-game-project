# Technical Implementation Details

## Architecture Overview

### Game State Machine

The game uses a simple state machine with three states:

```gdscript
enum GameState { START, PLAYING, GAME_OVER }
```

**State Transitions:**
```
START → PLAYING → GAME_OVER → START
         ↑_________________│
         (restart_game)
```

### Menu System Components

#### 1. StartScreen Node (`scripts/start_screen.gd`)
**Purpose**: Display menu UI and handle user input

**Key Methods:**
- `_ready()` - Connect button signals
- `_update_high_score()` - Fetch and display high score from Main
- `_input(event)` - Accessibility: tap/click anywhere fallback
- `_on_start_pressed()` - Button click handler
- `_start()` - Transition to gameplay

**Signal Connections:**
```gdscript
start_button.pressed.connect(_on_start_pressed)
```

#### 2. Main Node (`scripts/main.gd`)
**Purpose**: Game state orchestration, high score persistence

**Key Methods:**
- `_ready()` - Load high score, initialize menu
- `start_game()` - Reset state, enable gameplay
- `_game_over()` - Check/save high score
- `_save_high_score(value)` - Write to disk
- `_load_high_score()` - Read from disk

**High Score Variables:**
```gdscript
var high_score: int = 0  # Current best score (persisted)
var score: int = 0       # Current game score (temporary)
```

### High Score Persistence

#### Storage Format
- **File**: `user://highscore.dat`
- **Format**: Binary 32-bit unsigned integer
- **Location**: User-specific directory (survives game reinstalls)

#### Save Method
```gdscript
func _save_high_score(value: int) -> void:
    var file := FileAccess.open("user://highscore.dat", FileAccess.WRITE)
    if file:
        file.store_32(value)
```

#### Load Method
```gdscript
func _load_high_score() -> int:
    if not FileAccess.file_exists("user://highscore.dat"):
        return 0
    var file := FileAccess.open("user://highscore.dat", FileAccess.READ)
    if file:
        return file.get_32()
    return 0
```

#### Update Logic
```
Main._game_over()
    │
    ├─ Check: score > high_score?
    │   ├─ YES: high_score = score
    │   │         _save_high_score(high_score)
    │   │
    │   └─ NO: (do nothing)
    │
    └─ Return to menu
        └─ StartScreen._update_high_score()
            └─ Display "Best: {high_score}"
```

---

## Scene Hierarchy

```
Main (Node2D)
├── Background (ColorRect)
├── PlatformManager (Node2D)
├── Player (CharacterBody2D)
├── Camera2D
└── HUD (CanvasLayer)
    ├── HUDContainer (VBoxContainer)
    │   └── ScoreLabel (Label) [In-game score display]
    ├── StartScreen (VBoxContainer) [Menu]
    │   ├── TitleLabel (Label)
    │   ├── Spacer1 (Control)
    │   ├── Spacer2 (Control)
    │   ├── HighScoreLabel (Label)
    │   ├── Spacer3 (Control)
    │   └── StartButton (Button) ← NEW
    └── GameOverScreen (VBoxContainer)
        ├── GameOverLabel (Label)
        ├── Spacer1 (Control)
        ├── FinalScoreLabel (Label)
        ├── BestScoreLabel (Label)
        ├── Spacer2 (Control)
        └── RestartButton (Button)
```

---

## Input Handling

### Primary Input: Button Signal
```gdscript
# In StartScreen._ready()
start_button.pressed.connect(_on_start_pressed)

# Button press triggers
_on_start_pressed() → _start() → main_node.start_game()
```

### Accessibility Input: Direct Events
```gdscript
func _input(event: InputEvent) -> void:
    if not visible:
        return
    if event is InputEventScreenTouch and event.pressed:
        _start()
    elif event is InputEventMouseButton and event.pressed:
        _start()
```

**Why Both Methods?**
- **Button**: Clear, discoverable, standard UX
- **Tap/Click Anywhere**: Accessibility for players who might not see or expect a button

---

## Signal Flow Diagram

```
┌─────────────────────────────┐
│   StartButton (Button)      │
│   (part of StartScreen)     │
└──────────────┬──────────────┘
               │ pressed signal
               ↓
     ┌─────────────────────────────┐
     │ StartScreen._on_start_...() │
     └──────────────┬──────────────┘
                    │ calls
                    ↓
          ┌─────────────────────────────┐
          │   StartScreen._start()      │
          │   (calls main_node.start_.. │
          └──────────────┬──────────────┘
                         │
                         ↓
        ┌─────────────────────────────────┐
        │   Main.start_game()             │
        │   • Change state to PLAYING     │
        │   • Reset score, position       │
        │   • Enable player physics       │
        │   • Show HUD, hide menu         │
        └─────────────────────────────────┘
```

---

## Data Flow: High Score

```
┌─────────────────┐
│ Game Starts     │
└────────┬────────┘
         │
         ↓ (Main._ready())
    ┌────────────────────┐
    │ FileAccess.open()  │ ← Load from disk
    │ file.get_32()      │
    └────────┬───────────┘
             │
             ↓
    ┌────────────────────┐
    │ Main.high_score    │
    │ variable set       │
    └────────┬───────────┘
             │
             ↓ (StartScreen._update_high_score())
    ┌────────────────────────────────┐
    │ HighScoreLabel.text = "Best: X"│
    └────────┬───────────────────────┘
             │
         [Gameplay happens]
             │
             ↓ (Main._game_over())
    ┌────────────────────┐
    │ if score > high_.. │
    │    high_score = sc │
    │    _save_high_..() │
    └────────┬───────────┘
             │
             ↓ (FileAccess.open() for WRITE)
    ┌────────────────────┐
    │ file.store_32()    │ ← Save to disk
    │ user://highscore.. │
    └────────────────────┘
```

---

## UI State Management

### Menu Visible States

| Screen | Visible | HUD | Purpose |
|--------|---------|-----|---------|
| StartScreen | `true` | `false` | Initial menu |
| GameOverScreen | `false` | `false` | (not shown) |
| HUDContainer | `false` | `false` | (not shown) |

### Gameplay Visible States

| Screen | Visible | HUD | Purpose |
|--------|---------|-----|---------|
| StartScreen | `false` | `false` | (not shown) |
| GameOverScreen | `false` | `false` | (not shown) |
| HUDContainer | `true` | `true` | Score display |

### Game Over Visible States

| Screen | Visible | HUD | Purpose |
|--------|---------|-----|---------|
| StartScreen | `false` | `false` | (not shown) |
| GameOverScreen | `true` | `false` | Game over UI |
| HUDContainer | `false` | `false` | (not shown) |

---

## Thread Safety & Performance

### File I/O Timing
- **Load**: At game startup (single call, non-blocking)
- **Save**: At game over (single call, low frequency)
- **Impact**: Negligible (< 1ms per operation)

### Memory Usage
- **High Score**: 1 integer (4 bytes)
- **Menu References**: 2 node references (button, label)
- **Total Overhead**: Minimal

---

## Godot-Specific Details

### Version Compatibility
- **Engine**: Godot 4.x
- **Script Language**: GDScript
- **Scene Format**: `.tscn` (text-based)

### Key Godot Patterns Used

1. **@onready Annotation**
   ```gdscript
   @onready var start_button: Button = $StartButton
   # Automatically caches node reference after _ready()
   ```

2. **Signal Connection**
   ```gdscript
   start_button.pressed.connect(_on_start_pressed)
   # Non-blocking event-driven input
   ```

3. **Node Tree Navigation**
   ```gdscript
   get_node_or_null("/root/Main")
   # Safe cross-scene communication
   ```

4. **Visibility Notification**
   ```gdscript
   NOTIFICATION_VISIBILITY_CHANGED
   # Triggers when node visibility changes
   ```

---

## Testing Approach

### Unit Level
- ✅ `StartScreen._update_high_score()` - Check label updates
- ✅ `Main.start_game()` - Check state transition
- ✅ `Main._save_high_score()` / `_load_high_score()` - Check file I/O

### Integration Level
- ✅ Menu → Gameplay transition
- ✅ Gameplay → Game Over transition
- ✅ Game Over → Menu transition
- ✅ High score persistence across all states

### User Acceptance Testing
- ✅ Menu appears on startup
- ✅ High score displays
- ✅ Button is clickable
- ✅ Game launches after click
- ✅ High score saves after game over

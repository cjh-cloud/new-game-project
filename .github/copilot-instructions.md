# Copilot Instructions for GGGamez Platform Game

## Project Overview
This is a **Godot 4.x platformer game** with a scene-based architecture. The game features a player character navigating through various platform types in a level-based gameplay loop.

## Architecture & Component Boundaries

### Scene Structure (`scenes/`)
- **`main.tscn`**: Root game scene, orchestrates game states and screen transitions
- **`player.tscn`**: Player character node with physics and input handling
- **`platforms/`**: Three platform types, each with unique behaviors:
  - `normal_platform.tscn`: Static platforms
  - `moving_platform.tscn`: Platforms that move along paths
  - `breakable_platform.tscn`: Platforms that break after player contact

### Script Organization (`scripts/`)
Each scene has a paired GDScript (`*.gd`) file implementing node-specific logic:
- **`main.gd`**: Game state machine (start screen → gameplay → game over)
- **`player.gd`**: Player movement, jumping, collision detection
- **`platform_manager.gd`**: Spawns and manages platform instances
- **`hud.gd`**: Score/status display updates
- **`game_over_screen.gd` / `start_screen.gd`**: UI screen logic

## Data Flow & Critical Patterns

### Game Loop


### Platform System
- `platform_manager.gd` spawns platforms at runtime
- Each platform type inherits base platform behavior but overrides `_process()` for unique mechanics
- Platforms communicate player contact via signals → HUD score update

### Player-Platform Interaction
- Player (`player.gd`) detects platform collisions
- Platforms trigger state changes (breakable platforms track break state)
- Moving platforms update player position via parent transforms

## Godot-Specific Conventions

### File Naming
- Scenes: `snake_case.tscn` (e.g., `normal_platform.tscn`)
- Scripts: Match scene name with `.gd` extension (e.g., `normal_platform.gd`)
- UID files: Generated metadata (`.gd.uid`, `.tscn.uid`) - do NOT edit

### Scene Structure Patterns
- Parent nodes implement `_ready()` for initialization
- Use `_process(delta)` for per-frame logic
- Communicate between nodes via signals, not direct references

## Development Workflows

### Adding a New Platform Type
1. Create `scenes/platforms/new_platform.tscn` (inherit from Node2D)
2. Create `scripts/new_platform.gd` with unique logic
3. Register in `platform_manager.gd`
4. Test collision behavior with `player.gd`

### Debugging
- Use Godot debugger (F5) to step through state transitions in `main.gd`
- Monitor `player.gd` velocity/collision flags for movement issues
- Check output panel for platform spawn logs

## Key Dependencies & Gotchas

- **Physics**: All platforms use `CharacterBody2D` or `StaticBody2D`; collision layers are critical
- **Signal cleanup**: Disconnect signals in `_exit_tree()` to prevent memory leaks
- **Manager references**: `platform_manager.gd` must be reliably instantiated for spawning
- **Godot version**: Check `project.godot` config_version for engine compatibility
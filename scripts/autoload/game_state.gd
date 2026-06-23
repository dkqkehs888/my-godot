extends Node

## Shared runtime state for the project.
## Keep this minimal; add fields only when a feature needs global state.

var debug_enabled: bool = true

func reset() -> void:
    debug_enabled = true

# Plan

## Current batch (2026-10-31)

| # | Milestone | Branch | Status | PR |
|---|-----------|--------|--------|----|
| 1 | Implement the newly added SFX | `implementing-sfx` | 🟡 in progress (code + test done, committed locally, not pushed) | — |

### Decisions
- Branch cut from `main` at `727fc87` after a pull. Local debug edits (QTE timers 5–10s, stale `main_scene` uid / 4.6 tag) were dropped in favour of upstream; they remain in `stash@{0}`.
- Godot MCP confirmed connected after the pull (v1.2.1, port 6505); only warnings in the error log.

### 1. Implement the newly added SFX
- **Found:** `SFX` autoload (`scripts/main/sfx.gd`) already plays the UI `style_1` set (hover, press, menu_open/close, purchase, cant_afford). Unused so far: stat-up sounds (`health_up`, `luck_up`, `energy_per_tap_up_1..3`) and QTE sounds (`qte_success`, `qte_fail`, `basketball_swish`, `chalk_write`, `paper_pickup_1..4`, `paper_rip`, `bunot`).
- **Backend / data:** none. Extend `SFX` with a `play_random` variant helper and load the stat/QTE sounds.
- **Wiring:** stats shop `_upgrade` plays the matching stat-up sound; `BaseQTE` `finished` plays `qte_success` / `qte_fail`; per-QTE sounds (swish → timing bar, chalk → math, paper_rip → slice, paper_pickup → trash).
- **UI:** none visible.
- **Test:** headless script in `tests/` asserting every SFX stream loads and `play()` works for each name.
- **Files:** `scripts/main/sfx.gd`, `scripts/stats/stats_shop.gd`, `scripts/qte/*.gd`, `tests/test_sfx.gd`.

### Not checked
- Audible quality/volume balance; `style_2` UI set and `Music/` duplicates deliberately left unused.

## Previous batch
(none)

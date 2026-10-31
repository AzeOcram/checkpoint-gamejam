# Plan

## Current batch (2026-10-31, 2nd)

| # | Milestone | Branch | Status | PR |
|---|-----------|--------|--------|----|
| 1 | Full friend list: all 39 friends, sorted by SB, locked ones shaded, buy from the list | `friend-list-buy` | 🔵 PR open (UI approved) | [#29](https://github.com/AzeOcram/checkpoint-gamejam/pull/29) |

### Decisions
- Sorted by SB price (`recruitment_cost`), cheapest first (changed from SB generation after PR review). Ties break by `social_battery_generation`, then name. Order is static, so a purchase never reshuffles the list.
- Locked friends get a dark overlay on the whole card (portrait, text), a "Befriend · N SB" button instead of the three stat bars.
- Buy-from-list reuses `RecruitmentSystem.can_recruit` / `recruit_friend` (rules stay there); unaffordable press plays `cant_afford`.
- There are 40 friends (not 39); the header now reads `x/40` from `available_friends` instead of the stale `MAX_FRIENDS := 39`.
- `can_recruit` now also returns false while a recruitment is in progress, so Befriend buttons grey out during a QTE.

### 1. Full friend list
- **Found:** `friends_panel.gd` builds cards only from `recruitment_system.friends` (recruited). Buying lives in `friend_map.gd` + `friend_info_panel.gd` (click a seat on the map first). `recruitment_system.available_friends` already holds all 39 `FriendData`.
- **Backend / data:** none. Panel builds one card per `available_friends`, sorted once, and flips a card to unlocked on `friend_recruited` (no rebuild).
- **UI:** `FriendCard.setup` branches on `data.unlocked`: locked = `modulate` darken (same `0.35` grey the map nodes use) + cost + Befriend button; unlocked = today's bars. Hover tint and press scale 0.96 on the button, 150ms ease-out, reuse `SFX` meta (`sfx_press`, `sfx_blocked`). Button disabled-look when SB < cost.
- **Test:** extend `tests/test_friend_list.gd`: 39 cards at start, non-decreasing SB order, locked cards dimmed, recruiting flips only that card to unlocked, header count stays recruited/39, unaffordable buy is refused.
- **Files:** `scripts/main/friends_panel.gd`, `scripts/main/friend_card.gd`, `scenes/main/friend_card.tscn`, `tests/test_friend_list.gd`.

### Not checked
- Scroll feel with 39 cards at 320x180; Befriend press while a QTE is already queued.

## Previous batch (2026-10-31)

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

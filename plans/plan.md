# Plan

## Current batch (2026-10-31, 5th)

| # | Milestone | Branch | Status | PR |
|---|-----------|--------|--------|----|
| 1 | Friend QTE countdown = `friend_data.duration`; frequency stays `friend_qte_timer_min/max` | `fix/friend-qte-duration` | ✅ merged | [#35](https://github.com/AzeOcram/checkpoint-gamejam/pull/35) |
| 2 | Re-apply keyboard shortcuts (#34) after revert #36; restore the dropped `key_hint.gd` ext_resource in `main.tscn` | `feat/keyboard-shortcuts-v2` | 🟡 in progress (tests green, PR next) | — |

### What I found
- **The two settings are mixed up in the code.** `FriendQTE.start` (`scripts/qte/friend_qte.gd`) sets the on-screen countdown with `randf_range(friend_qte_timer_min, friend_qte_timer_max)`. Those fields are the *frequency* range (20-140s in the data), so a friend QTE can count down for up to 140 seconds.
- **The manager's value is ignored.** `FriendQTEManager.start_qte` sets `qte_data.duration = 5.0`, but `FriendQTE` only reads `qte_data.duration` when it has no friend, which never happens in game.
- **Frequency is already right.** `FriendNode.start_mood_timer` (`friend.gd`) rolls `randf_range(friend_qte_timer_min, friend_qte_timer_max)` per cycle, and `apply_friend_crisis` shifts the same two fields. Nothing else uses them, so item 2 needs no code change once item 1 removes the mix-up; it gets a test that pins it.
- **`duration` today:** `FriendData.duration` (default 10.0, in the "Recruitment QTE" export group) is only used by the recruitment QTE. No friend `.tres` overrides it, so every friend's countdown becomes 10s until you set a per-friend value.

### Decisions
- Reuse the existing `FriendData.duration` for both the recruitment QTE and the friend QTE, as asked (one field, one meaning: "how long the QTE countdown runs"). Open question: do you want a separate field later so the two can differ?
- The manager sets `qte_data.duration = friend_data.duration`, and `FriendQTE` always counts down from `qte_data.duration`, so the rule sits in one place.
- No change to the 10s alert timer, the warning banner or the frequency logic.

### 1. Countdown and frequency
- **Backend / data:** `friend_qte_manager.gd`: `qte_data.duration = friend_data.duration` (was 5.0). `friend_qte.gd`: delete the `randf_range(min, max)` block, use `time_remaining = qte_data.duration` for both branches.
- **UI:** none. The "TIME: x" label shows the new value.
- **Test:** `tests/test_friend_qte_timing.gd` (headless, real `main.tscn`): set a friend's `duration` to 7 and `friend_qte_timer_min/max` to 100/140, click the alert, assert the QTE `time_remaining` is 7; change `duration` to 3 for a second friend and assert 3. Frequency: for a friend with min 20 and max 40, assert every started mood timer `wait_time` is within 20..40 over 200 rolls, and that after `apply_friend_crisis` the range shifts down by 5. Run red first (it fails today: `time_remaining` would be 100-140).
- **Skills used:** diagnosing-bugs (reproduce the 100-140s countdown), tdd (red test first), blast-radius (other readers of `duration`, `friend_qte_timer_*`), run (frame capture of the timer), pr (PR body).
- **Files:** `scripts/friends/friend_qte_manager.gd`, `scripts/qte/friend_qte.gd`, `tests/test_friend_qte_timing.gd`.
- **Order:** one branch from an up-to-date `main`, one PR. It does not depend on #33 or #34.

### 2. Re-apply keyboard shortcuts
- **Found:** #34 was merged, then reverted by #36. The merge commit that resolved the #33 conflict (`dbfafbd`) kept the `KeyHint` node in `main.tscn` but dropped its `ext_resource` line for `key_hint.gd`, so the `KeyHint` script reference was dangling. The likely reason for the revert.
- **Fix:** revert the revert on a fresh branch from `main`, add the missing `ext_resource` line, rerun `test_shortcuts.gd` plus the warning, alert, timing and friend-list tests (all pass).
- **Files:** same as #34 (`ui.gd`, `pause_menu.gd`, `key_hint.gd`, `main.tscn`, `project.godot` input actions, `tests/test_shortcuts.gd`).

### Not checked
- Game balance at 10s: it is much shorter than today's 20-140s, so friend QTEs get far harder until you tune `duration` per friend.
- Whether anything else in the scene relied on the old long countdown (for example the timer label width at "TIME: 10.0").

## Previous batch (2026-10-31, 4th)

| # | Milestone | Branch | Status | PR |
|---|-----------|--------|--------|----|
| 1 | Fix alert/timer popups covered by other friends | `fix/alert-popup-overlap` | ✅ merged | [#32](https://github.com/AzeOcram/checkpoint-gamejam/pull/32) |
| 2 | Persistent "A FRIEND NEEDS YOU!" warning | `feat/friend-warning` | 🔵 PR open (UI awaiting approval) | [#33](https://github.com/AzeOcram/checkpoint-gamejam/pull/33) |
| 3 | Keyboard shortcuts (S shop, F friends) + fading hint | `feat/keyboard-shortcuts` | ⚪ not started | — |

### Answer first: how often does a friend QTE fire?
- **It is a per-friend random timer, not a fixed interval and not a trigger condition.** `FriendNode.start_mood_timer` rolls `randf_range(friend_qte_timer_min, friend_qte_timer_max)` seconds (`friend.gd`). The roll is new every cycle.
- **Starts** the moment the friend is recruited (`_complete_recruitment` -> `setup`). Each friend's clock is independent.
- **Ranges** in `resources/friends/*.tres` run from 20-60s up to 100-140s (min 20-100, max 60-140). Friends with a short range alert often; the shy ones rarely.
- **Pauses** while that friend has an open alert (10s) or a QTE queued/active. **Restarts** only when the QTE finishes or the alert expires, so the real gap is wait + reaction + QTE time.
- **Only two things change it:** (1) connection reaches 100 -> that friend never alerts again (`pause_monitoring`); (2) a friend crisis (mood hits 0 after a failed QTE) permanently subtracts 5s from min and max of every other friend (floored at 0). Mood itself does not change the frequency.
- **Risk found:** repeated crises can push min and max to 0, so those friends alert again almost instantly. Not part of this batch.

### Decisions
- 3 branches, 3 PRs, in this order. Each starts from an up-to-date `main`. 2 and 3 do not depend on 1.
- Warning (2): shown while any friend alert is open or a friend QTE is queued/active, hidden when none remain. Text "A FRIEND NEEDS YOU!". Size: about 15% of the screen height, width fits the text (open to change, one constant). Sits bottom-centre (top-centre hid the QTE prompt text), on its own `CanvasLayer` above the classroom, friend list, shop, friend QTE and event QTE.
- Warning excluded from the day intro cutscene. The game over, victory and main menu screens are separate scenes, so it is gone there without extra code.
- Shortcuts (3): `S` toggles the shop, `F` toggles the friend list, same open/close/swap behaviour and sounds as the two buttons. Ignored during any QTE, the intro and while paused.
- Hint (3): small `S` and `F` key badges next to the shop (bottom-right) and friend-list (bottom-left) buttons. Full opacity for 60s after the intro ends, then fade out over 4s (opacity only). The brief says "gradually disappear or fade after one minute": I read it as 60s shown, then a fade.

### 1. Fix alert/timer popups covered by other friends
- **Reproduced:** recruited all 40 and alerted all. In the screenshot the `! 10` labels of the lower rows are cut by the sprites of the seats after them (`all_alerts.png`, scratchpad).
- **Diagnosis (cause A, confirmed):** the label is a child of its own `FriendMapNode`. Seats draw in tree order (spawn order), and each sprite is 36px on a 16px grid so it overlaps the neighbours. Any later seat paints over an earlier seat's label. The label also sits one row up, over the friend in front, so it is unclear whose it is.
- **Diagnosis (cause B, likely, not reproduced):** clicks have the same problem. Each `TextureButton` is a full square and picking follows tree order (`friend_map.gd` already notes this), so a later seat's rectangle can swallow a click meant for an alerted friend behind it. My scripted hover test pointed at the Social Battery bar instead (coordinate mapping), so this is unconfirmed until step 1 below.
- **Step-by-step fix:**
  1. (done, cause B confirmed: 11 of 40 clicks on the lower body went to another friend before the fix) Test first in `tests/test_friend_alert.gd`: alert every friend, assert each alerted seat is drawn above all non-alerted seats and a click on each alerted seat's centre reaches that seat (synthetic mouse events through the viewport). Run it red.
  2. `FriendMapNode.show_alert`: set `z_index = 90` (above all seats and the labels, below the info panel at 100 and QTEs at 200). `hide_alert` resets it.
  3. `FriendMap._on_alert_changed` (first time only): `move_child(seat, info_panel.get_index() - 1)` so picking order matches draw order; remember the old index and restore it in `_on_alert_ended`.
  4. Anchor the label to the alerted friend's own head (centred over the sprite top), keep the outline.
  5. If cause B stays unreproducible after step 1, keep steps 2 and 4 only and say so in the PR.
  6. Rerun alert, friend list and SFX tests; screenshot with all 40 alerted.
- **Skills used:** diagnosing-bugs (reproduce, hypothesis, fix loop), tdd (red test first), blast-radius (who else relies on seat order: friend panel click, `update_friend_visual`), run (scripted frame capture), pr (PR body).
- **Files:** `scripts/friends/friend_map_node.gd`, `scripts/friends/friend_map.gd`, `tests/test_friend_alert.gd`.

### 2. Persistent friend warning
- **Found:** QTE scenes are `Control`s at `z_index = 200` added to the root; the day intro is a `CanvasLayer`; game over and victory are `change_scene_to_file`, so a `CanvasLayer` in `main.tscn` never shows there. `FriendQTEManager` already knows when an alert is open and when a QTE is active.
- **Backend / data:** `FriendQTEManager` gains `warning_active() -> bool` (any alert open, or a queued/active friend QTE) and a `warning_changed(active: bool)` signal, emitted from alert open/close and `_on_qte_finished`. The rule stays in the manager.
- **UI:** new `scenes/main/friend_warning.tscn` + `scripts/main/friend_warning.gd` on a `CanvasLayer` (layer 60) in `main.tscn`. Red text with outline on a dark rounded bar, 15% of viewport height, top-centre. Pop in/out by opacity and scale, 200ms ease-out, `PROCESS_MODE_ALWAYS` so it shows over the paused QTE. Hidden while the intro plays.
- **Test:** `tests/test_friend_warning.gd`: hidden at start; shown on an alert; stays shown while the QTE runs and while the friends and shop panels are open; hidden when the last alert/QTE finishes; stays up with two alerts until both are done; hidden during the intro.
- **Skills used:** tdd, domain-modeling (name "alert" vs "warning" consistently), blast-radius (QTE queue and finish paths), run, pr.
- **Files:** `scripts/friends/friend_qte_manager.gd`, `scripts/main/friend_warning.gd`, `scenes/main/friend_warning.tscn`, `scenes/main/main.tscn`, `tests/test_friend_warning.gd`.

### 3. Keyboard shortcuts
- **Found:** `ui.gd` already toggles the two panels from `_on_social_circle_button_pressed` and `_on_character_button_pressed`. The only input actions are `tap` (mouse, space) and `pause` (Esc). `S` and `F` are free.
- **Backend / data:** two new input actions in `project.godot`: `open_shop` (S), `open_friends` (F). `project.godot` has your local uncommitted edits, so I stage only my lines.
- **UI:** `ui.gd._unhandled_input` calls the existing two handlers. Ignored while a QTE is active, the intro is playing or the tree is paused. New `key_hint.gd` on two small key badges by the buttons: full opacity 60s after the intro, then an opacity-only fade over 4s, then hidden. No animation on the key presses themselves (keyboard-driven).
- **Test:** `tests/test_shortcuts.gd`: `S` opens the shop, again closes; `F` opens the friend list; `S` while friends is open swaps; both ignored during a QTE; hint at full opacity at 59s, fading after 60s, hidden after 64s.
- **Skills used:** tdd, blast-radius (`tap` also binds space; make sure `S`/`F` do not add energy or double-fire the tap), run, pr.
- **Files:** `project.godot` (my lines only), `scripts/main/ui.gd`, `scripts/main/key_hint.gd`, `scenes/main/main.tscn`, `tests/test_shortcuts.gd`.

### Not checked
- Cause B (click picking) is unconfirmed until step 1 of milestone 1.
- Whether the banner at 15% height covers the "Honesty" sign or the top HUD in a way you dislike (a screenshot will show it).
- Controller/touch input for shortcuts (not asked).
- `test_stats_system.gd` fails and hangs; I have not checked whether it also does on `main`.

## Previous batch (2026-10-31, 3rd)

| # | Milestone | Branch | Status | PR |
|---|-----------|--------|--------|----|
| 1 | Friend `!` + 10s timer popup; click the friend to start their QTE | `feat/ui-alert-and-timer` | ✅ merged (UI approved) | [#31](https://github.com/AzeOcram/checkpoint-gamejam/pull/31) |

### Decisions
- A friend QTE no longer starts by itself. When a friend's mood timer fires, an alert (`!` + countdown) appears over that friend on the map for 10s; clicking the friend enqueues the QTE.
- Clicking an alerted friend starts the QTE and does not open the info panel. Unalerted friends behave as today.
- Alerts run concurrently, one per friend (a friend with an open alert has its mood timer paused, as now). Alerts keep counting while another QTE is on screen.
- Expiry (user's answer): counts as a failed QTE, same penalty path as failing (mood/connection drop, crisis check), then the friend's mood timer restarts.
- Clicking again after the QTE is queued does nothing (alert is cleared on click).

### 1. Friend alert popup
- **Found:** `FriendNode.request_friend_qte` → `FriendQTEManager._on_friend_request_qte` enqueues the QTE immediately. `FriendMapNode` (the seat sprite on the map) has no link to the recruited `FriendNode`; both share `FriendData`. Map clicks go through `FriendMap._on_friend_clicked`.
- **Backend / data:** `FriendQTEManager` owns alert state (`alerts: Dictionary` of `FriendData` → time left, `ALERT_DURATION := 10.0`), ticks it in `_process`, emits `alert_started/alert_ended(friend_data)`. New `start_qte(friend_data)` enqueues the QTE (existing code moved out of the request handler). Expiry calls the existing `_on_qte_finished(FAILURE, node)`. Rules stay in the manager.
- **UI:** `FriendMapNode` gets a small `Label` child (`! 9`) above the sprite, hidden by default, shown on `alert_started`, updated each second, hidden on end. Pop-in scale/opacity tween (150-200ms ease-out), press scale 0.96 on the sprite while alerted, text turns red under 3s. `FriendMap` routes an alerted click to `start_qte` instead of the panel, and connects the manager signals to the matching map node.
- **Test:** `tests/test_friend_alert.gd` (headless, same pattern as `test_friend_list.gd`): request makes an alert and enqueues no QTE; two friends alert concurrently; clicking enqueues exactly that friend's QTE; unclicked alert after 10s applies the failure penalty and restarts the timer; alerted click does not open the info panel.
- **Files:** `scripts/friends/friend_qte_manager.gd`, `scripts/friends/friend_map.gd`, `scripts/friends/friend_map_node.gd`, `scenes/friends/friend_map_node.tscn`, `tests/test_friend_alert.gd`.

### Not checked
- Visual fit of the `!` at 320x180 with 16px seat spacing (screenshot after build); alert behaviour while the map is hidden by another screen.

## Previous batch (2026-10-31, 2nd)

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
| 1 | Implement the newly added SFX | `implementing-sfx` | 🟡 in progress (code + test done, committed locally, not pushed) | [#31](https://github.com/AzeOcram/checkpoint-gamejam/pull/31) |

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

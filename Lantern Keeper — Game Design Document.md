# Lantern Keeper — Game Design Document

Oct 18, 2026 · @Jeremy Patrick Callinan

Lantern Keeper is a 2D top-down arcade game for Windows: keep five coastal lamps burning through a stormy night so passing ships don't wreck. This is the example GDD for the CIST 1422 *Game Design Document and Project Plan* assignment. Its plan lives on the [example GitHub project](https://github.com/jcallinan/CIST1422-Example-Project-Plan), and every feature below matches a card on that board.

**Team:** Maya (programming) and Jordan (art and UI) · **Engine:** Unity 6, 2D URP · **Framework:** MDA

## 1. Concept and pitch

**Elevator pitch:** You are the last lighthouse keeper on a rocky coast during a storm. Ships pass through the night, and every coastal lamp burns through its oil. Run between lamps, refuel them, and keep the coast lit until dawn, because a ship that passes a dark lamp wrecks on the rocks.

- **Genre:** single-player arcade / time-management, played in short sessions (one night is about 6 minutes)
- **Target player:** casual players who like quick, frantic juggling games, ages 10 and up; no reading or prior gaming skill needed beyond WASD
- **It's like:** *Overcooked*'s plate-spinning panic meets *Don't Starve*'s light-versus-darkness, shrunk to one screen
- **Why it's fun:** there are always more lamps than you can tend at once, so every second is a small decision about which one to save next

## 2. Framework analysis (MDA)

The target feeling is **Challenge**, with a touch of **Fantasy**: the player should feel frantic but in control, like a keeper holding back the storm alone. We designed from that aesthetic backward to the mechanics that create it.

| Layer | What it is in Lantern Keeper |
| --- | --- |
| **Aesthetics** (what the player feels) | *Challenge:* constant pressure, with every save earned. *Fantasy:* being the lone keeper on a storm-lashed coast. A little *Discovery* as the player learns efficient routes. |
| **Dynamics** (what happens in play) | Triage: the player constantly ranks lamps by fuel and by how close the next ship is. Route planning between lamps. Risk-taking: leave a half-full lamp to grab an oil barrel? Tension rises as storms speed everything up. |
| **Mechanics** (rules and inputs) | Five lamps lose fuel every second. The keeper carries a limited oil can and refuels by holding E. Ships spawn on a timer and follow the shipping lane. A ship passing a dark lamp wrecks and costs 1 of 3 lives. Surviving to dawn wins. |

**How the layers connect:** draining fuel plus too many lamps to watch (mechanics) forces triage (dynamics), and constant triage is what makes the night feel like a challenge (aesthetics). If playtesters feel bored, fuel drains too slowly. If they feel helpless, ships come too often. Both are tuning numbers in section 7, not new features.

## 3. Core gameplay loop

Every 20 seconds or so, the player runs through the same four steps, and each ship that passes judges how well they did.

&#91;embedded content: core gameplay loop · 4 steps, ship outcomes\]

1. **Check the coast:** which lamp is lowest, and which ship arrives next?
2. **Run to a lamp:** pick a route around the rocks.
3. **Hold E to refuel:** 25 fuel per second from the oil can.
4. **Refill the oil can** at the lighthouse or an oil barrel, only when the can runs low.

Meanwhile a ship passes every 12 seconds: a lit lamp saves it (+100 points), a dark lamp wrecks it (−1 life).

When the oil can still has fuel, the keeper skips step 4 and goes straight back to checking the coast. The loop never lets up, because a full lamp lasts only 25 seconds and the lap takes 20.

## 4. Controls

Keyboard only, playable with one hand on WASD; the mouse is used only in menus.

| Input | Action | Notes |
| --- | --- | --- |
| W A S D | Move the keeper | 8 directions, normalized so diagonals aren't faster |
| E (hold) | Refuel the nearest lamp | Only within 1.5 tiles; a prompt appears when in range; transfers 25 fuel per second |
| Walk over a barrel | Refill the oil can | Automatic pickup |
| Left Shift (hold) | Sprint | *Nice to have:* 1.6× speed, but spills 2 oil per second |
| Esc | Pause / resume | Pausing stops fuel drain, ships, and timers |
| Mouse | Menu buttons | Main menu, pause menu, game-over screen |

## 5. Look and feel

The screen is a dark, rain-soaked coastline where the only warm color is lamplight, so the player's eye goes straight to what matters.

- **Art style:** 16×16 pixel art, drawn at 4× scale (64 px per tile on a 1280×720 screen). Simple shapes with readable silhouettes.
- **Palette:** deep navy and slate for sea, rock, and sky; amber and gold reserved for lamp light, fuel, and the keeper's lantern. A dark lamp is visibly grey, so danger is readable at a glance.
- **Camera:** fixed top-down orthographic camera showing the whole coast at once, so no lamp is ever off-screen.
- **Lighting:** URP 2D lights. Each lamp is a point light whose radius shrinks as fuel drops, so fuel level is shown in the world as well as on the HUD.
- **HUD:**
  - top left: lives as three small lighthouse icons
  - top center: dawn timer (sun rising on a progress bar)
  - top right: the keeper's oil can level
  - above each lamp: a small fuel bar that turns red under 25%
- **Audio:** rain and wind ambience under a slow, tense loop. A foghorn warns 3 seconds before a ship reaches a lamp. Refueling makes a pouring sound and wrecks a heavy crunch. The music speeds up during storms.
- **Mood board:** stormy lighthouse photography, the night levels of *Celeste*, and the lighting of *Alto's Odyssey* (reference images go in the repo's `/docs/moodboard` folder).

## 6. World and content

The game takes place on a single hand-built coastline level; replay value comes from storms and random barrel drops, not from more levels.

**The level:** a 20×11-tile coast. The lighthouse stands in the center, five lamps are spread along the shoreline, and rocks and cliffs force the keeper onto winding paths. The shipping lane runs left to right just offshore. A full lap past all five lamps takes about 20 seconds, too long to keep every lamp topped up.

| Element | Role | Key rules |
| --- | --- | --- |
| **Keeper** (player) | The only character the player controls | Walks at 4 tiles/sec; the oil can holds 100 fuel and refills at the lighthouse or from barrels |
| **Lamps** (5) | The resource being protected | 100 fuel max; drain 4 fuel/sec at the start of the night; dark at 0 |
| **Ships** | The threat | Spawn off-screen every 12 sec, sail the lane at 1.5 tiles/sec, check each lamp as they pass |
| **Oil barrels** | *Should have:* a risky shortcut | Wash up at random shore spots, at most 2 at a time; each refills 50 fuel |
| **Storms** | *Should have:* difficulty spikes | Every 2 minutes, a 3-second warning, then fuel drains 1.5× faster and ships come 1.5× as often for 30 sec |

**Story:** told in one opening line, *"The old keeper is gone. Tonight, the coast is yours."*, and a sunrise at the end. No dialogue system.

## 7. Win, lose, and progression

A night lasts 6 minutes. Survive until the dawn timer runs out to win; lose all 3 lives and the night ends early.

- **Start:** all lamps begin at 100 fuel, the oil can is full, and the first ship arrives after 10 seconds so the player can get their bearings.
- **Win:** the dawn timer reaches 0 with at least 1 life left. The sunrise plays, then the score screen appears.
- **Lose:** the third wreck ends the night. The game-over screen offers Retry or Main Menu.
- **Score:** ships saved × 100, plus 500 per life left at dawn. The best score is saved locally.
- **Difficulty curve:** each storm (at 2:00, 4:00, and 5:30) is stronger than the last. Storm 1 multiplies fuel drain and ship frequency by 1.5×, storm 2 by 1.75×, and the final storm by 2× right before dawn, so the night ends on its tensest moment.

**Tuning numbers** (exposed in the Inspector so playtesting can adjust them without code changes):

| Setting | Starting value |
| --- | --- |
| Night length | 360 sec |
| Lamp fuel drain | 4 fuel/sec |
| Refuel rate | 25 fuel/sec |
| Ship spawn interval | 12 sec |
| Keeper speed | 4 tiles/sec |
| Lives | 3 |

## 8. Technical scope

Lantern Keeper is built in Unity 6 (2D URP) for a Windows build that runs on the VR Lab PCs, with no online features.

- **Engine and packages:** Unity 6 LTS, Universal Render Pipeline (2D Renderer for lights), Input System, 2D Tilemap, TextMeshPro, Cinemachine (camera shake on wrecks only).
- **Version control:** GitHub with the Unity `.gitignore`. Each task is a GitHub issue, and commits close issues with `Closes #N`.
- **Main scripts:**
  - `KeeperController`: movement, sprint, and the oil can
  - `Lamp`: fuel drain, light radius, and a `WentDark` event
  - `ShipSpawner` and `Ship`: spawn timing, lane movement, and the dark-lamp check
  - `GameManager`: lives, dawn timer, storms, and win/lose state
  - `HUD`: reads values from the GameManager and the lamps; doesn't change game state
- **Data:** a `NightSettings` ScriptableObject holds every tuning number from section 7.
- **Third-party assets:** none planned. If the pixel-art risk triggers, we'll use a CC0 asset pack from itch.io or Kenney.nl, credited on the credits screen.
- **Out of scope:** multiplayer, saving mid-night, more than one level, controller support.

## 9. Project plan

The plan lives on the [Lantern Keeper GitHub project](https://github.com/jcallinan/CIST1422-Example-Project-Plan): 28 issues, each with a scope tier, an hour estimate, an owner, and a milestone.

| Tier | Features |
| --- | --- |
| **Must have** | Movement, lamps and fuel, refueling, ships and wrecks, lives and dawn timer, HUD, menus, credits, Windows build |
| **Should have** | Oil barrels, storms, pixel-art tiles and sprites, sound effects |
| **Nice to have** | Music and volume slider, sprint, gameplay trailer |

Milestones: Plan Approved (Oct 27), Prototype (Nov 10), Alpha (Nov 24), Beta (Dec 1), Final Build (Dec 8). Three risks are tracked on the board as `risk` issues: ship movement, pixel-art time, and midterms plus Thanksgiving week.

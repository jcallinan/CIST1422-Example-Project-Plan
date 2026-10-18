# Lantern Keeper — Example Project Plan (CIST 1422)

This repository is an **example** of the Project Plan part of the *Game Design Document and Project Plan* assignment. The game itself is never built here — the point is to show what a good plan looks like in GitHub Projects so you can build your own.

Open the **Projects** tab of this repository to see the board.

---

## The game (one-paragraph GDD summary)

**Lantern Keeper** is a 2D top-down game for Windows built in Unity. You are a lighthouse keeper on a rocky coast during a storm. Ships pass through the night, and every coastal lamp burns through its oil. Run between lamps, refuel them, and keep the coast lit until dawn. If a ship passes a dark lamp, it wrecks on the rocks and you lose a life. Lose three lives and the night is over.

- **MDA aesthetic target:** Challenge and a little Fantasy. The player should feel frantic but in control.
- **Core loop:** Check which lamp is lowest → run to it → refuel → watch for incoming ships → repeat.
- **Controls:** WASD to move, E to refuel a lamp, Shift to sprint (stretch goal), Esc to pause.
- **Look:** 16×16 pixel art, a dark blue-and-amber palette, a top-down camera, and a HUD with lives, a dawn timer, and fuel bars over each lamp.

## Scope tiers

| Tier | What's in it |
|---|---|
| **Must have** | Movement, lamps with draining fuel, refueling, ships that wreck at dark lamps, lives and a dawn timer, HUD, menus, a Windows build |
| **Should have** | Oil barrel pickups, storms that ramp difficulty, real pixel art, sound effects |
| **Nice to have** | Music and volume settings, a sprint upgrade, a trailer |

If time runs short, the Nice-to-have items get cut first, then Should-have. The Must-have tier alone is still a complete, playable game.

## Milestones

| Milestone | Due | Done when… |
|---|---|---|
| Plan Approved | Tue Oct 27 | GDD and board submitted and approved |
| Prototype | Tue Nov 10 | Core loop is playable with grey boxes |
| Alpha | Tue Nov 24 | Every Must-have feature is in |
| Beta | Tue Dec 1 | Content complete, playtested, bug fixing |
| Final Build | Tue Dec 8 | Windows build, presentation, credits |

## Risks

Risks are tracked as issues labeled `risk` so they stay visible on the board:

1. **Ship movement may take longer than expected.** Fallback: ships follow fixed paths instead of steering.
2. **Pixel art is time-consuming.** Fallback: keep the greybox and use a free asset pack (credited on the credits screen).

---

## How to read the board

| Field | Meaning |
|---|---|
| **Status** | Todo → In Progress → Done. Drag cards across the Board view. |
| **Scope** | Must have / Should have / Nice to have |
| **Estimate (hrs)** | A guess at the hours needed. Tasks over ~4 hours should be split up. |
| **Milestone** | Which checkpoint the task belongs to |
| **Target date** | Drives the Roadmap view |
| **Labels** | The area of work: `gameplay`, `ui`, `art`, `audio`, `tech`, `testing`, `docs`, `risk` |

Every issue has **acceptance criteria**, a checklist that defines "done." If you can't write acceptance criteria for a task, it isn't specific enough yet.

## Make your own board in 10 minutes

1. Create a GitHub repo for your game (use the **Unity** `.gitignore` template).
2. Go to your profile → **Projects** → **New project** → choose the **Board** template.
3. In the project's **Settings**, link it to your repo.
4. Add custom fields: **Scope** (single select), **Estimate (hrs)** (number), **Target date** (date).
5. In your repo, open **Issues → Milestones** and create your four or five milestones with due dates.
6. Create one issue per task. Give each one a label, a milestone, and acceptance criteria, then add it to the project.
7. Add a **Roadmap** view (grouped by Milestone) and a **Table** view (grouped by Scope).
8. Teams: add your teammates as collaborators and assign each issue to a person.
9. Share the project with your instructor and screenshot the Board view for your submission.

*Tip:* write `Closes #12` in a commit message and GitHub closes issue #12 and moves its card to **Done** automatically.

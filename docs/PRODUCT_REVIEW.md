# Gangnam Dream Product Review

## 2026-05-16 Prototype Completion Gap Review

### Current Strengths
- Core turn-loop concept is legible: the player immediately understands income, expenses, stats, and choices.
- Event system is data-driven and already contains 584 result texts, giving the game immediate narrative density.
- Investment system supports multi-asset trading with buy tiers, partial sell, and profit display.
- Relationship, news, save, meta-progression, and ending systems are all scaffolded.
- Balance tracking structure is in place and already logging meaningful tuning decisions.
- The project is organized for GitHub, QA, build notes, balance, and IP tracking.

### Main Gaps Before Playable Alpha Quality
- Save/load is scaffolded but not fully validated across multi-slot saves, loaded state restoration, and future-proof serialization.
- Meta-progression is declared but not implemented: unlockable traits, hidden backgrounds, and starting bonuses do not yet affect runs.
- Event variety thins out quickly. The roadmap targets 100+ life events, 30 investment events, 30 relationship events, and 20 hidden rare events — current content does not reach these numbers.
- Notification system exists in code but is not connected to the main UI, so key feedback is missing during play.
- Appearance stat is stored but has no mechanical effect yet.
- Godot editor runtime QA has not been completed; all current validation is static.
- IP expression is underdeveloped: no app icon direction, no store capsule concept, and the title is not finalized in Korean and English.

### Recommended Feature Priorities
1. Full save/load validation: multi-slot, state restoration (portfolio, relationships, flags, inventory, logs), and compatibility after content additions.
2. NotificationToast integration into MainGame scene so action feedback reaches the player.
3. Appearance stat implementation: connect to at least one event condition and one relationship outcome.
4. Meta-progression first pass: unlock one starting trait and one hidden background through normal run completion.
5. Content expansion: reach the Roadmap Content Alpha targets for events across all categories.
6. Runtime QA pass in Godot 4.6 editor: boot, turn loop, events, investment, relationships, save/load, endings.
7. IP direction pass: confirm Korean and English title, draft store icon concept, define visual symbol.

### Management Questions To Ask Before Implementation
- Should save-slot count be fixed at launch or configurable by the player?
- Should meta-progression unlocks be tied to ending grade, total run count, or specific achievement flags?
- Should the appearance stat affect relationship outcomes, job requirements, or event unlock conditions?
- Should the notification toast queue multiple messages or show only the most recent per turn?
- Should the first public playtest happen before or after the Content Alpha event targets are met?
- Does the Korean writing tone need a dedicated review pass before the Alpha build?

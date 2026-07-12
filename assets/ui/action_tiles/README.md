# AP Action Tile Assets

`action_core_atlas.png` is the canonical Gangnam Ink illustration atlas for the four recurring AP cards.

| Region | Key | Meaning |
|---|---|---|
| `0,0,512,512` | `job` | Work / career |
| `512,0,512,512` | `money` | Money / investing |
| `0,512,512,512` | `study` | Self-development |
| `512,512,512,512` | `rest` | Rest / recovery |

Runtime crops each square into a 76x48 covered thumbnail. The source is intentionally dark, object-focused, person-free, and text-free so it survives Steam Deck scale and Moral Tint grading.

Do not map this art by broad stat category. A submenu action may use a core tile only when it depicts the same action. Side work, saving, market analysis, resume writing, and interview preparation keep distinct SVG fallbacks until they receive dedicated illustrations.

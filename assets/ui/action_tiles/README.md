# AP Action Tile Assets

The six PNG atlases are the canonical Gangnam Ink illustrations for recurring AP cards and their highest-frequency subactions.

## Core

| Region | Key | Meaning |
|---|---|---|
| `0,0,512,512` | `job` | Work / career |
| `512,0,512,512` | `money` | Money / investing |
| `0,512,512,512` | `study` | Self-development |
| `512,512,512,512` | `rest` | Rest / recovery |

## Career And Money

| Region | Key | Meaning |
|---|---|---|
| `0,0,512,512` | `resume` | Cover-letter writing |
| `512,0,512,512` | `interview` | Mock-interview practice |
| `0,512,512,512` | `side_job` | Gig / side work |
| `512,512,512,512` | `saving` | Saving / cutting back |

## Advanced Work

| Region | Key | Meaning |
|---|---|---|
| `0,0,512,512` | `market` | Market analysis |
| `512,0,512,512` | `startup` | Startup work |
| `0,512,512,512` | `content` | Content creation |
| `512,512,512,512` | `housing` | Moving house |

## Self-Development

| Region | Key | Meaning |
|---|---|---|
| `0,0,512,512` | `reading` | Reading |
| `512,0,512,512` | `exercise` | Exercise |
| `0,512,512,512` | `meditation` | Meditation |
| `512,512,512,512` | `invest_study` | Investment study |

## Social And Risk

| Region | Key | Meaning |
|---|---|---|
| `0,0,512,512` | `people` | Relationships / networking |
| `512,0,512,512` | `gambling` | Gambling entry |
| `0,512,512,512` | `routine` | Passing weeks / routine |
| `512,512,512,512` | `date` | Time with a partner |

## Gambling Venues

| Region | Key | Meaning |
|---|---|---|
| `0,0,512,512` | `racetrack` | Racetrack |
| `512,0,512,512` | `holdem` | Underground Hold'em |
| `0,512,512,512` | `scalping` | Scalp trading |
| `512,512,512,512` | `casino_venue` | Jeongseon Casino |

Runtime crops each square into a 112x84 scene strip on the weekly board and a 108x56 strip in action modals. A dedicated action-art Moral material lifts midtones at Gray because the full-background edge treatment crushes detail at thumbnail scale; Black still corrodes the image and White restores source color. Sources remain object-focused, person-free, and free of meaningful text.

Do not map this art by broad stat category. Every key belongs to one action fantasy; never substitute `money` merely because an action affects money. SVGs are reserved for small functional controls and true art fallbacks, not recurring AP decisions.

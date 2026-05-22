# Gangnam Dream Audio Prompts

Use these in Suno/Udio or another music generator. Export loops as `.ogg` or `.wav` for Godot.

## Main Theme - Seoul Survival

```text
lo-fi hip hop instrumental, gentle piano melody, soft dusty drums, nostalgic and slightly melancholy mood, Seoul late-night study room atmosphere, Korean indie game feeling, hopeful undertone beneath financial anxiety, warm tape texture, subtle city ambience, no vocals, seamless 2-3 minute loop
```

Suggested file:
- `game/assets/audio/bgm_main_seoul_survival.ogg`

## Crisis Theme - Health / Mental Risk

```text
tense ambient electronic instrumental, minimal drums, low bass hum, occasional sparse piano notes, urban stress and pressure, unsettling but not horror, dark Korean city night mood, restrained, no vocals, seamless 90 second loop
```

Suggested file:
- `game/assets/audio/bgm_crisis_pressure.ogg`

## Milestone Theme - Small Victory

```text
uplifting lo-fi instrumental with understated triumph, soft piano, warm synth pads, gentle beat, Korean indie pop influence, hopeful but not flashy, feeling of reaching a small life milestone after hardship, no vocals, seamless 60-90 second loop
```

Suggested file:
- `game/assets/audio/bgm_milestone_small_victory.ogg`

## Ending Theme - Gangnam Dream

```text
emotional orchestral lo-fi hybrid instrumental, bittersweet triumph, piano lead with soft strings and gentle beat, reflective Korean drama OST influence, feeling of finally reaching a long-sought goal but remembering the cost, no vocals, 2-3 minutes
```

Suggested file:
- `game/assets/audio/bgm_ending_gangnam_dream.ogg`

## Godot Integration Notes

- Put BGM files under `game/assets/audio/`.
- Prefer `.ogg` for looping BGM in Godot.
- Use `AudioStreamPlayer` for global music.
- Keep music volume lower than UI feedback so text choices stay readable.
- Suggested bus names: `Master`, `Music`, `SFX`, `UI`.

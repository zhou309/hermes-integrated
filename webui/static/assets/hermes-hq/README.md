# Hermes HQ Individual PNG Assets

This folder contains individual transparent PNGs split from the generated sprite sheets.

## Folders

- `characters/` — tight transparent character crops.
- `characters_normalized/` — same characters on a consistent 150x265 transparent canvas.
- `buildings/` — tight transparent building crops, no baked text.
- `buildings_normalized/` — same buildings on a consistent 380x310 transparent canvas.
- `rooms/` — tight transparent room/interior crops, no baked text.
- `rooms_normalized/` — same rooms on a consistent 380x420 transparent canvas.
- `sheets_clean/` — transparent versions of the source sprite sheets.
- `metadata/asset_manifest.json` — source bboxes, dimensions, and paths.

## Dashboard usage

Use the normalized folders when you want consistent placement and scaling.

Recommended CSS:

```css
.asset-pixel {
  image-rendering: pixelated;
  image-rendering: crisp-edges;
  position: absolute;
  transform-origin: bottom center;
}
```

Recommended anchor:
- Characters: bottom-center
- Buildings: bottom-center
- Rooms: bottom-center or center, depending on layout

Text should be rendered dynamically in HTML/CSS, not baked into these images.

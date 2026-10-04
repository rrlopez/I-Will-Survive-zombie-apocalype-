# Fonts

Place your `.ttf` or `.otf` font files here, then create matching `.tres` resources.

## Recommended setup (Phase 0)

1. Import a font (e.g. `Roboto-Regular.ttf`) into this folder.
2. In the Godot editor, right-click it → **New Resource** → `FontFile`.
3. Save as `font_8.tres` (size hint 8) and `font_16.tres` (size hint 16).
4. Uncomment the `fonts` dictionary in `autoloads/constants.gd`.

## Fallback

Until real fonts are imported, all labels use Godot's built-in default font,
which is fine for Phase 0 testing.

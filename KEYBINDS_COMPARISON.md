# Keybinds Comparison: Yours vs ilyamiro's

> **Changes made so far:**
> - `SUPER+C` → QS clipboard widget (was unbound) — added
> - `SUPER+V` → QS clipboard widget (was rofi+cliphist) — changed; rofi version commented
> - `SUPER+A` → QS volume widget (was unbound) — added
> - `SUPER+W` → QS wallpaper widget (was browser) — changed; browser keybind removed
> - `SUPER+P` → Play/pause media (kept as-is, matches ilyamiro's intent)
> - `SUPER+Q` → Close window (kept, rejected music widget — muscle memory)
> - `XF86PowerOff` → Lock screen (was unbound) — added
> - Idle lock timeout → 30 min (was 12 min) — changed in hypridle

## Single Modifier (SUPER + key)

| Key | Yours | ilyamiro |
|-----|-------|----------|
| `SUPER+Q` | Close window | toggle **music** widget |
| `SUPER+W` | QS wallpaper widget ✓ | toggle **wallpaper** widget ✓ |
| `SUPER+E` | File manager (kitty + yazi) | Launch nautilus |
| `SUPER+R` | Rofi app launcher | Reload Quickshell shell |
| `SUPER+T` | OCR selection (tesseract) | Launch Telegram |
| `SUPER+Y` | Toggle split | — |
| `SUPER+O` | TTS Kokoro GPU | Launch Obsidian |
| `SUPER+P` | Play/pause media | — |
| `SUPER+S` | Screenshot selection → clipboard | toggle **calendar** widget |
| `SUPER+D` | Smart float (90% + center) | toggle **applauncher** widget |
| `SUPER+F` | Fullscreen (mode 0) | Launch Firefox |
| `SUPER+H` | Focus left (Vim) | toggle **guide** widget |
| `SUPER+J` | Focus down (Vim) | — |
| `SUPER+K` | Focus up (Vim) | — |
| `SUPER+L` | Focus right (Vim) | Lock screen |
| `SUPER+Z` | Toggle scratchpad | — |
| `SUPER+X` | Pin window | — |
| `SUPER+C` | ~~Unbound~~ → QS clipboard widget ✅ | toggle **clipboard** widget |
| `SUPER+V` | ~~Rofi clipboard~~ → QS clipboard widget ✅ | toggle **volume** widget |
| `SUPER+B` | Color picker (hyprpicker) | toggle **battery** widget |
| `SUPER+N` | Toggle swaync panel | toggle **network** widget |
| `SUPER+M` | Lock screen (Quickshell) | toggle **monitors** widget |
| `SUPER+Return` | — | Launch terminal |
| `SUPER+SPACE` | Rofi system menu | Play/pause media |
| `SUPER+TAB` | Previous workspace | — |
| `SUPER+=` | Cursor zoom in | — |
| `SUPER+-` | Cursor zoom out | — |
| `SUPER+BACKSPACE` | Reset cursor zoom | — |
| `SUPER+,` | Toggle per-window blur | — |
| `SUPER+.` | Toggle per-window opacity | — |
| `SUPER+;` | Process terminator (TUI) | — |

## SUPER + SHIFT

| Key | Yours | ilyamiro |
|-----|-------|----------|
| `SUPER+SHIFT+Return` | Launch terminal (kitty) | — |
| `SUPER+SHIFT+F` | Maximize (fullscreen mode 1) | Toggle floating |
| `SUPER+SHIFT+D` | Toggle pseudo tile | — |
| `SUPER+SHIFT+H` | Move window left | — |
| `SUPER+SHIFT+J` | Move window down | — |
| `SUPER+SHIFT+K` | Move window up | — |
| `SUPER+SHIFT+L` | Move window right | — |
| `SUPER+SHIFT+S` | Annotate screenshot (swappy) | toggle **settings** widget |
| `SUPER+SHIFT+T` | OCR fullscreen (tesseract) | toggle **focustime** widget |
| `SUPER+SHIFT+O` | TTS Kokoro CPU | — |
| `SUPER+SHIFT+I` | STT Whisper CPU | — |
| `SUPER+SHIFT+Z` | Move to scratchpad | — |
| `SUPER+SHIFT+1-0` | Move window to WS 1-10 | Move window to WS 1-10 |
| `SUPER+SHIFT+SPACE` | Matugen theme config (rofi) | — |

## SUPER + CTRL

| Key | Yours | ilyamiro |
|-----|-------|----------|
| `SUPER+CTRL+arrows` | Move window direction | Move window direction |
| `SUPER+CTRL+SPACE` | Emoji picker (rofi) | — |
| `SUPER+CTRL+SHIFT+SPACE` | Calculator (rofi) | — |
| `SUPER+CTRL+=` | Display scale up | — |
| `SUPER+CTRL+-` | Display scale down | — |

## SUPER + ALT

| Key | Yours | ilyamiro |
|-----|-------|----------|
| `SUPER+ALT+W` | Waybar config swap | — |
| `SUPER+ALT+A` | Animation menu (rofi) | — |
| `SUPER+ALT+S` | Shader menu (rofi) | — |
| `SUPER+ALT+X` | Disable shaders | — |
| `SUPER+ALT+V` | Vibrance shader | — |
| `SUPER+ALT+D` | Hide all notifications | — |
| `SUPER+ALT+.` | Toggle global visuals | — |

## ALT (no SUPER)

| Key | Yours | ilyamiro |
|-----|-------|----------|
| `ALT+1` | Wi-Fi manager (wifitui) | — |
| `ALT+2` | Bluetooth manager (blueman) | — |
| `ALT+3` | Audio mixer (pavucontrol) | — |
| `ALT+4` | Wallpaper app (waypaper) | — |
| `ALT+6` | Passthrough mode toggle | — |
| `ALT+7` | Screen off (DPMS) | — |
| `ALT+8` | Screen on (DPMS) | — |
| `ALT+9` | Start waybar | — |
| `ALT+0` | Kill waybar | — |
| `ALT+R` | Reload Hyprland | — |
| `ALT+H` | Hyprsunset slider (rofi) | — |
| `ALT+V` | Volume slider (rofi) | — |
| `ALT+B` | Brightness slider (rofi) | — |
| `ALT+M` | Mute audio | — |
| `ALT+O` | Switch audio output | — |
| `ALT+I` | Switch mic input | — |
| `ALT+SHIFT+SPACE` | Power menu (rofi) | — |
| `ALT+F4` | — | Close window |

## No Modifier / Hardware Keys

| Key | Yours | ilyamiro |
|-----|-------|----------|
| `Print` | Annotate selection (swappy) | Screenshot selection |
| `SHIFT+Print` | Annotate fullscreen (swappy) | Screenshot + edit (satty) |
| `SUPER+Print` | — | Fullscreen screenshot |
| `SUPER+SHIFT+Print` | — | Fullscreen + edit (satty) |
| `CTRL+SHIFT+SPACE` | Keybind help (rofi) | — |
| `CTRL+SHIFT+ESC` | System monitor (btm) | — |
| `CTRL+ALT+SPACE` | UWSM uuctl (rofi) | — |
| `CTRL+ALT+DELETE` | Logout menu (wlogout) | — |
| `XF86PowerOff` | ~~Unbound~~ → Lock screen ✅ | Lock screen |
| `Caps Lock` | — | Caps lock OSD indicator |
| Volume/Brightness keys | swayosd-client | swayosd-client |
| `ALT+volume/brightness` | Precise adjustments | — |

## Workspaces

| Feature | Yours | ilyamiro |
|---------|-------|----------|
| Switch WS 1-10 | `hyprsome workspace N` | `qs_manager.sh N` |
| Move to WS 1-10 | `hyprsome move N` | `qs_manager.sh N move` |
| 3-finger swipe | — | Workspace switching |

## Mouse

| Key | Yours | ilyamiro |
|-----|-------|----------|
| `SUPER+LMB` | Move window | Move window |
| `SUPER+RMB` | Resize window | Resize window |

## Unbound (available)

| Key | Status |
|-----|--------|
| `SUPER+G` | Free |
| `SUPER+U` | Free |
| ~~`SUPER+A`~~ → QS volume widget ✅ | Used |
| `SUPER+SHIFT+G/U/A/P/B/N/M/W/E` | Free |
| `SUPER+ALT+G/U/A/P/B/N/M/E/T/Y/Z/X` | Free |

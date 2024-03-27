# Irizz Theme
Irizz Theme is an aesthetically pleasing design for [Soundsphere](https://soundsphere.xyz), emphasizing simplicity and keyboard control.

![Song select screenshot](screenshots/song_select.png?raw=true)

## Features

- Vim motions.
- Completely redesigned user interface for various game screens, including Song Select, Collections, Settings, and Result screen.
- New UI elements such as buttons, checkboxes, and more, redesigned for improved usability and visual appeal.
- Stylish and eye-catching visuals that provide a modern and polished look without being overwhelming.

## Planned Improvements

- Redesigned Multiplayer screen to match the visual style of other game screens.
- New Music Player screen

## Installation

1. Download the latest release ZIP archive from the "Releases" tab.
2. Extract the contents of the ZIP archive.
3. Copy the "ModulePatcher" and "Irizz-theme" mods into the `moddedgame` directory within the game's root folder. If the `moddedgame` directory does not exist, create it.
4. Done. Launch the game.

## Customization

Currently, basic customization is supported through the following methods:

- UI Tab in settings.
- Customize controls in `userdata/keybinds.lua` or `userdata/vim_keybinds.lua`.
- Add background images to `userdata/backgrounds/`. If the chart does not have it's own background image, random image from this directory will be loaded instead.
- Add color themes to `userdata/color_themes/`. You can find an example in `irizz/color_themes/Default.lua`

Table of overridable files:
| Type  | Path                                          | Description                                           |
|-------|-----------------------------------------------|-------------------------------------------------------|
| Image | userdata/avatar                               | Your avatar you see in the header                     |
| Image | userdata/game_icon                            | Game icon in the header                               |
| Sound | userdata/ui_sounds/scroll_large_list          | Scrolling chart sets, collections and osu!direct sets |
| Sound | userdata/ui_sounds/scroll_small_list          | Scrolling charts and osu!direct charts                |
| Sound | userdata/ui_sounds/checkbox_click             |                                                       |
| Sound | userdata/ui_sounds/button_click               |                                                       |
| Sound | userdata/ui_sounds/slider_moved               |                                                       |
| Sound | userdata/ui_sounds/tab_button_click           | Switching tabs in settings                            |
| Sound | userdata/ui_sounds/song_select_screen_changed | Pressing on the screen buttons in the header          |

Note: you should specify the file format. For sound - mp3, wav, ogg. For images - png, jpg.

## Compatibility and Updates

- It is recommended to turn off automatic updates for the base game if the Irizz Theme is working correctly to avoid potential compatibility issues.
- Update the base game only when a new version of the Irizz Theme is available, as frequent updates can break compatibility.

## Screenshots

![Settings screenshot](screenshots/settings.png?raw=true)
![Result screenshot](screenshots/result.png?raw=true)
![Modifiers_screenshot](screenshots/modifiers.png?raw=true)

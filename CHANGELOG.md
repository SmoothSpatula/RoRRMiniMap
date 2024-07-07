### v1.0.0
* Initial release

### v1.0.1
* Fixed surface error crashing the game

### v1.0.2
* The map is now generated only once on entering a stage, for greater performance
* You can now change the map's alpha
* Fixed an issue where the map would toggle when typing in chat
* ImGui will now prevent you from entering a non-valid key for toggling the map

### v1.0.3
* Tried to solve an issue where surfaces weren't being freed correctly

### v1.0.4
* The map now displays all players with their respective colours
* Updated way to change keybind
* Fixed the map not working in Local Multiplayer

### v1.0.5
* The map now updates when changing zoom scale, works with QuickZoom mod

### v1.0.6
* Added player names on the minimap
* changed tp colour to make it stand out more and added a text
* Solved issue where the minimap would always fit to width even it if should fit to height (more work to be done to show non-displayed parts of the level)

### v1.0.7
* Solved overlapping/clipping issues
* Interactables now disappear when they can no longer be activated
* Small reformatting

### v1.0.8
* Added an x and y offset
* Removed the MINIMAP text at the top

### v1.0.9
* Fixed oChest4, oShop1, oShop2 not disappearing on use
* Reduced dynamic variable allocation
* Added center map on player option
* Added hide yourself option

### v1.0.10
* Fixed oShop1 not appearing on the map

### v1.1.0
* Fixed minimap appearing dark sometimes (hopefully)
* Changed the way surfaces are used, hopefully it can fix the crash some people were getting

### v1.1.1
* Attempt to fix "attempt to index a number value" error that was crashing the game

# [mpv-bookmarker](https://github.com/NurioHin/mpv-bookmarker)

## Keybinds

Left hand                  | Right hand
---------------------------|---------------------------
Key        | Function      | Key        | Function
---        | ---           | ---        | ---
  w        | jumpSlot(-1)  |   h        | jumpPage(-1)
  a        | jumpPage(-1)  |   j        | jumpSlot(1)
  s        | jumpSlot(1)   |   k        | jumpSlot(-1)
  d        | jumpPage(1)   |   l        | jumpPage(1)
  e        | open          |   o        | open
  z        | move          |   ENTER    | open
  v        | addBookmark() |   m        | move
  r        | replace       |   u        | delete
  D        | delete        |   P        | addBookmark()
  V        | save          |   p        | replace
  c        | rename        |   O        | save
  f        | filepath      |   i        | rename
  ESC      | abort() end   |   BS       | delete
           |               |   DEL      | delete
           |               |   UP       | jumpSlot(-1)
           |               |   RIGHT    | jumpPage(1)
           |               |   LEFT     | jumpPage(-1)
           |               |   DOWN     | jumpSlot(1)

Open `bookmarker-menu.lua` in a text editor, and you can easily change these settings:

#### When the Bookmarker menu is closed
  `.`:          Pull up the Bookmarker menu
  `Alt+.`:      Quickly add a new bookmark
  `Ctrl+.`:     Quickly load the latest bookmark

#### When the Bookmarker menu is open
  `.`:          Close the Bookmarker menu
  `ESC`:        Close the Bookmarker menu
  `UP/DOWN`:    Navigate through the bookmarks on the current page (Hold to quickly scroll)
  `LEFT/RIGHT`: Navigate through pages of bookmarks (Hold to quickly scroll)
  `ENTER`:      Load the currently selected bookmark
  `DELETE`:     Delete the currently selected bookmark
  `s`:          Save a bookmark of the current media file and position
  `shift+s`:    Save a bookmark of the current media file and position (shows a text input, allowing you to type)
  `p`:          Replace the currently selected bookmark with the current media file and position
  `r`:          Rename the currently selected bookmark (shows a text input, allowing you to type)
  `f`:          Change the filepath of the currently selected bookmark (shows a text input, allowing you to type)
  `m`:          Move the currently selected bookmark

#### When allowing text input
  `ESC`:        Cancel text input and return to the Bookmarker menu
  `ENTER`:      Confirm text input and save/rename the bookmark
  `LEFT/RIGHT`: Move the cursor through the text, allowing you to input text in different places (Hold to quickly scroll)
  `BACKSPACE`:  Remove the character preceding the cursor (Hold to rapidly remove multiple)
  `DELETE`:     Remove the character after the cursor (Hold to rapidly remove multiple)
  `Any char`:   Type for the text input. Allows special characters, spaces, numbers. Does not allow letters with accents (Hold to rapidly add characters)

#### When moving bookmarks
  `ESC`:        Cancel moving and return to the Bookmarker menu
  `ENTER`:      Confirm moving the bookmark
  `m`:          Confirm moving the bookmark
  `s`:          Save a bookmark of the current file and position
  `UP/DOWN`:    Navigate through the bookmarks on the current page (Hold to quickly scroll)
  `LEFT/RIGHT`: Navigate through pages of bookmarks (Hold to quickly scroll)

During text input for a bookmark's name, you can write `%t` or `%p` to input a timestamp in the name. (Note: This does not work for a bookmark's filepath.)

  `%t` is a timestamp in the format of hh:mm:ss.mmm
  `%p` is a timestamp in the format of S.mmm

For example, `Awesome moment @ %t` will show up as `Awesome moment @ 00:13:41.673` in the menu


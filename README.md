# .dotfiles

Bash, Zsh, iTerm, Atom, Vim, Tmux, Git, OSX, Brew, npm, rvm etc.

![Console](./screens/console.png?raw=true)

[All screens](./screens)

## Install

Use `bootstrap.sh` to install all at once (never tested haha). Or run individual scripts.

To apply only dotfiles run `install.sh`.

### zsh

To switch to `zsh` as your login shell grab it from the brew and add this to `/etc/shells`:

```
/usr/local/bin/zsh
```

Then run:

```
chsh -s $(which zsh)
```

### iTerm

Use [this patch](https://github.com/jaredculp/iterm2-borderless-padding) to add breathing room to your `iTerm` (mine is 30px).

### Others

I use [`kwm`](https://github.com/koekeishiya/kwm) to manage windows. And [`Übersicht`](http://tracesof.net/uebersicht/) to reduce the noise from menu bar.

## Keyboard Shortcuts

#### ProTip #1
Remap your CapsLock to Ctrl.

```
System Preferences > Keyboard > Keyboard > [Modifier Keys...]
```

#### ProTip #2
Use F1 – F5 keys as standard function keys for your keybindings.

```
System Preferences > Keyboard > Keyboard > [x] Use F1, F2, ...
```

#### ProTip #3
Use F7 – F12 keys for iTunes and volume controls (via Alfred or whatever).

### Cheatsheets

`*` means not standard.

#### Global

```
* <Cmd-F1>             Toggle Console                      Alfred
* <Cmd-F2>             Toggle Atom                         Alfred
* <Cmd-F3>             Toggle Browser                      Alfred

  <Ctrl-F2>            Show menu bar
  <Ctrl-F3>            Show dock
* <Alt-Space>          Show Alfred                         Alfred
* <Ctrl-Space>         Create TODO in Things               Things

  <Cmd-Ctrl-A>         Set Space Tiling Mode To BSP        KWM
  <Cmd-Ctrl-S>         Set Space Tiling Mode To Monocle    KWM
  <Cmd-Ctrl-D>         Set Space Tiling Mode To Float      KWM
  <Cmd-Ctrl-F>         Set current window to float         KWM
  <Cmd-Ctrl-B>         Toggle active border                KWM
  <Cmd-Ctrl-M>         Mark/Swap current window            KWM
* <Cmd-Ctrl-Enter>     Maximize/Restore current window     KWM
* <Cmd-Ctrl-Arrow>     Focus window in direction           KWM
* <Cmd-Ctrl-[/]>       Focus next/previous window          KWM
* <Cmd-Alt-Arrow>      Swap w/ next window                 KWM
* <Cmd-Shift-Up/Down>  Change split-ratio                  KWM
* <Cmd-Ctrl-0>         Focus primary display               KWM
* <Cmd-Ctrl-9>         Focus secondary display             KWM
* <Cmd-Alt-0>          Move window to primary display      KWM
* <Cmd-Alt-9>          Move window to secondary display    KWM

* <Ctrl-Shift-←>       Go to the left space                System Preferences > Mission Control
* <Ctrl-Shift-→>       Go to the right space               System Preferences > Mission Control
  <Ctrl-1>             Go to Space 1                       System Preferences > Mission Control
  <Ctrl-2>             Go to Space 2                       System Preferences > Mission Control
  <Ctrl-N>             Go to Space N                       System Preferences > Mission Control
  F3                   Toggle Mission Control              System Preferences > Mission Control
  F4                   Toggle Launchpad                    System Preferences > Keyboard > Shortcuts > Launchpad & Dock
* F5                   Toggle Full Screen Mode             System Preferences > Keyboard > Shortcuts > App Shortcuts
* F6                   Toggle Do Not Disturb Mode          System Preferences > Keyboard > Shortcuts > App Shortcuts
```

#### iTerm

```
  <Cmd-N>                 New Window
  <Cmd-T>                 New Tab
  <Cmd-D>                 New Pane on the Right
  <Cmd-Shift-D>           New Pane on the Bottom
  <Cmd-K>                 Clear history
  <Cmd-Right>             Next Tab
  <Cmd-Left>              Previous Tab
  <Cmd-Number>            N Tab
  <Cmd-]>                 Next Pane
  <Cmd-[>                 Previous Pane
  <Cmd-Alt-Arrow/Number>  Navigate Panes
  <Cmd-Ctrl-Arrow>        Resize Pane
  <Cmd-Shift-Enter>       Maximize/Restore Pane
```

#### Atom

```
                          ### Common
  <Cmd-.>                 Show keybinding resolver
* <Ctrl-Shift-p>          Toggle command palette
  <Cmd-Shift-p>

                          ### File lists (Tree View, Fuzzy Finder etc.)
* <Cmd-Enter>             New split on the right
* <Cmd-Shift-Enter>       New split on the bottom
  <Cmd-k> Arrow           New split on provided direction
* s                       New split on the right (Tree View only)
* i                       New split on the bottom (Tree View only)

                          ### Tree View
* F1                      Toggle Tree View
  a                       Add file
  A                       Add folder
* r                       Rename
* d                       Delete
* c                       Duplicate
  <Cmd-Number>            Open file in N Pane
* \                       Find current file in the tree (in Normal mode)
  <Cmd-\>                 Toggle focus on Tree view (in all modes)

                          ### Fuzzy Finder
* <Cmd-r>                 Toggle buffer finder
* <Cmd-t>                 Toggle file finder

                          ### Advanced open file
* <Cmd-o>                 Toggle dialog
  /                       Go to the user's root
  :/                      Go to the project's root
* <Cmd-Enter>             New split on the right
* <Cmd-Shift-Enter>       New split on the bottom
  <Cmd-k> Arrow           New split on provided direction


                          ### Panes / Buffers
* F2                      Maximize current
* <Ctrl-Arrow>            Move around
  <Cmd-k> Arrow           Copy current into new split on provided direction
* <Cmd-Ctrl-Alt-Arrow>    Move current to new split in provided direction
* <Cmd-Ctrl-w>            Close others (in current split)

                          ### Editor - All modes
* <Cmd-o>                 Open file via `advanced-open-file`

  <Ctrl-Shift-l>          Toggle syntax selector
* <Cmd-l> j               Set Babel ES6 JavaScript language
* <Cmd-l> r               Set JavaScript (JSX) language

* <Alt-Up>                Scroll half screen up
* <Alt-Down>              Scroll half screen down

* <Cmd-d>                 Duplicate line
  <Cmd-Ctrl-Up>           Move line up
  <Cmd-Ctrl-Down>         Move line down
* <Ctrl-Shift-/>          Align stuff

                          ### Editor - Normal mode
  Tab                     Indent
  <Shift-Tab>             Un-indent
* <Shift-Alt-Up>          Move line up
* <Shift-Alt-Down>        Move line down
  i                       Go to Insert mode (place cursor before char)
  a                       Go to Insert mode (place cursor after char)
  s                       Remove selected char(s) and go to Insert mode
  I                       Move to the beginning of the line and go to Insert mode
  A                       Move to the end of the line and go to Insert mode
  O                       Insert line above and go in Insert mode
  o                       Insert line below and go in Insert mode
* +                       New line above (w/o going in Insert mode)
* =                       New line below (w/o going in Insert mode)
  w                       Move to the beginning of the next word
  W                       Move to the beginning of the next word (ignore commas, dots etc., only spaces are separators)
  e                       Move to the end of the next word
  E                       Move to the end of the next word (ignore commas, dots etc., only spaces are separators)
  b                       Move to the beginning of the previous word
  B                       Move to the beginning of the previous word (ignore commas, dots etc., only spaces are separators)
  f <char>                Search froward for the <char> (stop on the <char>)
  F <char>                Search backward for the <char> (stop on the <char>)
  t <char>                Search froward for the <char> (stop on the symbol before the <char>)
  T <char>                Search backward for the <char> (stop on the symbol before the <char>)
  ;                       Go forward to the next matched <char>
  ,                       Go backward to the previous matched <char>
  0                       Go to the beginning of the line
  ^                       Go to the first non-whitespace char on the line
  $                       Go to the end of the line
  r <char>                Replace char under cursor with <char>
  v                       Start selection
  V                       Select whole line
  y                       Copy selected
  yy                      Copy line
  x                       Cut selected
  p                       Paste
  d                       Start deletion
  dd                      Delete whole line
  D                       Delete rest of the line
  gg                      Go to the beginning of the file
  G                       Go to the end of the file
  H                       Go to the top of the screen
  M                       Go to the middle of the screen
  L                       Go to the end of the screen
  <num> G                 Go to the <num> line of the file
  <num> Enter             Go to the <num> line of the file

                          ### Settings
  <Cmd-,>                 Show default section
* <Cmd-,> k               Show Keybindings
* <Cmd-,> p               Show Packages
* <Cmd-,> i               Show Install
```

# .dotfiles
Bash, Zsh, iTerm, Atom, Vim, Git, OSX, Brew, npm etc.

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

### Others
I use [`chunkwm`](https://github.com/koekeishiya/chunkwm) to manage windows.


## Keyboard Shortcuts

#### ProTip
Remap your CapsLock to Ctrl.

```
System Preferences > Keyboard > Keyboard > [Modifier Keys...]
```

### Cheatsheets

`*` means not standard.

#### Global

```
* <Alt-Space>             Show Alfred                         Alfred
* <Ctrl-Space>            Create TODO in Things               Things
* <Ctrl-Alt-Space>        Run Project in iTerm                Alfred
* <Ctrl-Alt-T>            Open New iTerm Window               Alfred
* <Ctrl-Cmd-V>            Open Clipboard History              Alfred
* <Ctrl-Cmd-S>            Open Snippets                       Alfred
* <Ctrl-Cmd-U>            Open Url                            Alfred
* <Ctrl-Cmd-T>            Show/Hide Timer                     Billings Pro

* <Ctrl-Alt-A>            Set Space Tiling Mode To BSP        chunkwm
* <Ctrl-Alt-S>            Set Space Tiling Mode To Monocle    chunkwm
* <Ctrl-Alt-D>            Set Space Tiling Mode To Float      chunkwm
* <Ctrl-Alt-F>            Set current window to float         chunkwm
* <Ctrl-Cmd-Enter>        Maximize/Restore current window     chunkwm
* <Ctrl-Cmd-Arrow>        Focus window in direction           chunkwm
* <Ctrl-Alt-Arrow>        Swap w/ next window                 chunkwm
* <Ctrl-Cmd-1>            Focus primary display               chunkwm
* <Ctrl-Cmd-2>            Focus secondary display             chunkwm
* <Ctrl-Alt-1>            Move window to primary display      chunkwm
* <Ctrl-Alt-2>            Move window to secondary display    chunkwm

* <Ctrl-Shift-Left>       Go to the left space                System Preferences > Mission Control
* <Ctrl-Shift-Right>      Go to the right space               System Preferences > Mission Control
* F5                      Toggle Full Screen Mode             System Preferences > Keyboard > Shortcuts > App Shortcuts
* F6                      Toggle Do Not Disturb Mode          System Preferences > Keyboard > Shortcuts > App Shortcuts
```

#### iTerm

```
  <Cmd-N>                 New Window
  <Cmd-D>                 New Pane on the Right
  <Cmd-Shift-D>           New Pane on the Bottom
  <Cmd-Arrow>             Navigate Panes
  <Cmd-Shift-Arrow>       Resize Panes
  <Ctrl-Alt-Arrow>        Swap Panes
  <Cmd-K>                 Clear history
  <Ctrl-Cmd-Enter>        Maximize/Restore Pane
```

#### Atom

```
                      ### Common
  <Cmd-.>                 Show keybinding resolver
* <Ctrl-Cmd-P>            Toggle command palette

                      ### File lists (Tree View, Fuzzy Finder etc.)
* <Cmd-Enter>             New pane on the right
* <Cmd-Shift-Enter>       New pane on the bottom
  <Cmd-K> Arrow           New pane on provided direction
* s                       New pane on the right (Tree View only)
* i                       New pane on the bottom (Tree View only)

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
* <Cmd-R>                 Toggle buffer finder
* <Cmd-T>                 Toggle file finder

                      ### Advanced open file
* <Cmd-O>                 Toggle dialog
  /                       Go to the user's root
  :/                      Go to the project's root
* <Cmd-Enter>             New pane on the right
* <Cmd-Shift-Enter>       New pane on the bottom
  <Cmd-K> Arrow           New pane on provided direction


                      ### Git
* <Ctrl-Cmd-G>            Git: Toggle git panel
* <Ctrl-Cmd-H>            Git: Toggle Github panel
* <Ctrl-Cmd-B>            Git: Toggle git blame


                      ### Panes / Buffers
* <Ctrl-Cmd-Enter>        Maximize current
* <Ctrl-Cmd-Arrow>        Move around
* <Ctrl-Alt-Arrow>        Move current to new pane in provided direction
* <Ctrl-Alt-Q>            Destroy pane
* <Ctrl-Alt-W>            Close other buffers in current pane

                      ### Editor - All modes
* <Cmd-O>                 Open file via `advanced-open-file`

* <Ctrl-Cmd-T>            Find TODOs
* <Ctrl-Cmd-C>            Toggle color picker
* <Ctrl-Cmd-M>            Toggle Markdown preview

* <Ctrl-Cmd-/>            Toggle Nuclide diagnostic
* <Ctrl-Cmd->>            Toggle Nuclide tests runner

* <Ctrl-Cmd-L>            Toggle syntax selector
* <Cmd-L> s               Set Shell Script language
* <Cmd-L> j               Set Babel ES6 JavaScript language
* <Cmd-L> d               Set Docker language

* <Ctrl-↑>                Add cursor/selection above
* <Ctrl-↓>                Add cursor/selection below

* <Shift-↑>               Scroll half screen up
* <Shift-↓>               Scroll half screen down

* <Cmd-D>                 Duplicate line
* <Shift-Alt-↑>           Move line up
* <Shift-Alt-↓>           Move line down

* <Cmd-Shift-A>           Select all entries that match selection
* <Cmd-Shift-B>           Select all inside brackets

                      ### Editor - Normal mode
  Tab                     Indent
  <Shift-Tab>             Un-indent
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
* <Cmd-,> c               Show Core
* <Cmd-,> e               Show Editor
* <Cmd-,> k               Show Keybindings
* <Cmd-,> p               Show Packages
* <Cmd-,> t               Show Themes
* <Cmd-,> u               Show Updates
* <Cmd-,> i               Show Install
```

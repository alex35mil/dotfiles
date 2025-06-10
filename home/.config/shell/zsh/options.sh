typeset -U path cdpath fpath manpath
# ------------------------------------------
# - `typeset`: This is a built-in command used to set and display
#   attributes and values of shell parameters.
# - `-U`: This option specifies that the array values should be
#   unique. That is, any duplicate values will be removed automatically.
# - `path`, `cdpath`, `fpath`, `manpath`: These are all arrays.
#   By using `-U`, you ensure that each of these arrays will not
#   have any duplicate entries.
#
# Example:
# If `path` somehow got set to `("/usr/bin" "/usr/local/bin" "/usr/bin")`,
# the `-U` option would automatically trim it to
# `("/usr/bin" "/usr/local/bin")`.
# ------------------------------------------

fpath+=(
    $XDG_CONFIG_HOME/shell/zsh/completions
    $HOMEBREW_PREFIX/share/zsh/site-functions
    $HOMEBREW_PREFIX/share/zsh/$ZSH_VERSION/functions
    $HOMEBREW_PREFIX/share/zsh/vendor-completions
)
# ------------------------------------------
# `fpath` is a special array in zsh that specifies directories to search
# for autoloaded functions. When you want to load a function for the first time,
# zsh will look in these directories.
# ------------------------------------------

unalias run-help
autoload run-help
HELPDIR="$HOMEBREW_PREFIX/share/zsh/$ZSH_VERSION/help"
alias help=run-help
# ------------------------------------------
# Loads help modules provided by zsh and aliases `run-help` to `help`.
# ------------------------------------------

# ------------------------------------------
# COMPLETIONS
# ------------------------------------------

zmodload -i zsh/complist
# ------------------------------------------
# - `zmodload`: This is a zsh builtin command used to load or unload zsh modules.
#   Zsh modules extend the functionality of the shell by providing additional commands,
#   parameters, and features.
#
# - `-i`: This option ensures that if the module is already loaded, `zmodload` will
#   not produce an error. It's essentially an "ignore if already loaded" option.
#
# - `zsh/complist`: This is the name of a specific zsh module. The `complist` module
#   provides enhanced listing capabilities when performing command completion.
#   With this module loaded, when you press `Tab` to autocomplete a command or filename,
#   you might get a more advanced, possibly colorized, menu-like list of completions.
#
# By executing this command, you are ensuring the `complist` module is loaded, which
# enhances the visual display of tab completions in your zsh session.
# ------------------------------------------

autoload -U compinit && compinit
# ------------------------------------------
# - `autoload -U compinit`: This command loads the `compinit` function but
#   doesn't execute it immediately. Instead, it marks it for autoloading,
#   meaning it will be loaded and executed the first time it's called.
#   The `-U` option ensures that any previously defined aliases for `compinit`
#   are ignored, allowing for the actual function to be loaded.
#
# - `compinit`: Once autoloaded, this command is used to initialize the zsh
#   completion system. This is essential for providing tab-completion functionality
#   for commands, files, etc., in the zsh shell.
#
# In essence, this line ensures that the zsh completion system is loaded and initialized.
# ------------------------------------------

# ------------------------------------------
# - `zstyle`: This is a zsh command used to define styles for various parts of zsh's
#   functionality. Styles offer a flexible way to customize and control the behavior
#   of zsh, especially in areas like completion.
#
# - `':completion:*'`: This is a pattern that matches all contexts within the
#   completion system. It basically targets the entire completion system.
# ------------------------------------------

zstyle ':completion:*' rehash true
# ------------------------------------------
# - `rehash`: This is the style being set. When `rehash` is set to true, it tells
#   the completion system to automatically rehash (rebuild) the list of available
#   commands whenever a command not in the hash table is tried for completion.
#   In simpler terms, if you install a new program, zsh will automatically detect
#   and add it to its list of commands available for tab completion without requiring
#   you to manually rehash or restart the shell.
#
# By executing this command, you are ensuring that zsh's completion system always
# stays up-to-date with newly available commands on your system without manual
# intervention.
# ------------------------------------------

zstyle ':completion:*' menu select=1
# ------------------------------------------
# - `menu`: This style controls how the completion menu is displayed when there are
#   multiple possible completions.
#
# - `select=1`: The value `select=1` means that the menu-style completion list will
#   always be shown, even if there's only one possible completion. Additionally,
#   when the completion menu is displayed, the first item in the list will be
#   automatically selected, allowing you to cycle through the options using your
#   keyboard arrow keys.
#
# By executing this command, you are setting zsh to always show the completion menu
# (even for a single completion match) and to start with the first item pre-selected.
# This provides a consistent, interactive completion experience.
# ------------------------------------------

zstyle ':completion:*' group-name ''
# ------------------------------------------
# - `group-name`: This style determines how completion matches are grouped together
#   in the completion list. Typically, zsh groups completion items by type or source
#   (like "files", "aliases", "commands", etc.).
#
# - `''`: An empty string value for the style. By setting `group-name` to an empty
#   string, you're essentially disabling the named grouping feature. As a result,
#   completion matches will be displayed without any group names or headers.
#
# By executing this command, you ensure that completion listings don't display
# group names, providing a cleaner and more streamlined completion menu without
# categorical headers.
# ------------------------------------------

zstyle ':completion:*' list-colors ${(s.:.)LSCOLORS}
# ------------------------------------------
# - `list-colors`: This style is used to define the colors in which items in the
#   completion list are displayed, based on their file type or other attributes.
#
# - `${(s.:.)LS_COLORS}`: This is a parameter expansion in zsh. It takes the value
#   of the `LS_COLORS` environment variable (which defines color codes for different
#   file types in the `ls` command) and splits it at each colon (`:`) into an array.
#
# By executing this command, you're telling zsh's completion system to use the same
# color codes that `ls` uses, ensuring a consistent color scheme between file listings
# from the `ls` command and zsh's completion lists.
# ------------------------------------------

zstyle ':completion:*' list-rows-first
# ------------------------------------------
# - `list-rows-first`: This style controls the order in which completion items are
#   displayed when the list is presented in multiple columns.
#
# By executing this command without specifying a value, you're instructing zsh's
# completion system to list items row-by-row (horizontally) first, before moving to
# the next column, as opposed to the default column-by-column (vertically) listing.
#
# This results in a change in the visual layout of multi-column completion listings,
# where items are read from left to right, then top to bottom, rather than the default
# top to bottom, then left to right.
# ------------------------------------------

zstyle ':completion:*' special-dirs false
# ------------------------------------------
# - `special-dirs`: This style controls the behavior of completion with respect to
#   special directories, like `.` (current directory) and `..` (parent directory).
#
# - `true`: By setting this style to true, you're enabling the inclusion of these
#   special directories (`.` and `..`) in completion listings when appropriate.
#   For example, when completing a path, if you type `cd ..` and then press `Tab`,
#   zsh will include `..` in the list of potential completions.
#
# By executing this command, you are ensuring that the special directories (`.` and
# `..`) are always considered in path completions, providing a more thorough and
# complete list of potential directory navigations.
# ------------------------------------------

zstyle ':completion:*' verbose yes
# ------------------------------------------
# - `verbose`: This style controls the verbosity of the completion system.
#
# - `yes`: By setting the `verbose` style to "yes", you're instructing the completion
#   system to provide more detailed descriptions along with completion matches. For
#   instance, when completing commands, instead of just listing command names, zsh
#   might also show brief descriptions or explanations next to each command.
#
# By executing this command, you enhance the information provided by zsh's
# completion system, making it more descriptive and potentially aiding in the
# selection of the appropriate completion.
# ------------------------------------------

source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
# ------------------------------------------
# Activates zsh-autosuggestions plugin. This plugin provides
# real-time command autosuggestions as you type in the terminal, based on your
# command history and other factors.
# ------------------------------------------

# ------------------------------------------
# HISTORY
# ------------------------------------------

HISTFILE="$HOME/.zsh_history"
# ------------------------------------------
# This configuration line dictates that the zsh shell will save
# (and retrieve) the command history to (and from) a file at `.zsh_history`
# at HOME directory.
# ------------------------------------------

HISTSIZE="10000"
# ------------------------------------------
# Setting `HISTSIZE="10000"` means that the zsh shell will retain the last
# 10,000 commands you've entered. Once this limit is exceeded, older commands
# will start being removed from the beginning of the history to make room
# for newer commands.
# ------------------------------------------

SAVEHIST="10000"
# ------------------------------------------
# Setting `SAVEHIST="10000"` means that when you close or exit your zsh session,
# the last 10,000 commands from your command history will be saved to the
# history file (`~/.zsh_history` as set above).
# ------------------------------------------

[ -f "$HISTFILE" ] || { mkdir -p "$(dirname "$HISTFILE")" && touch "$HISTFILE"; }
# ------------------------------------------
# This command first checks if the file exists.
# If not, it then ensures the directory structure exists and subsequently creates the file.
# ------------------------------------------

# ------------------------------------------
# KEYBINDINGS
#
# `bindkey` is a zsh built-in command used to define or display keybindings.
# ------------------------------------------

bindkey -v
# ------------------------------------------
# - `bindkey -v`: In zsh, this command sets the keybindings to vi mode.
#   This means that when editing commands on the command line, you can use vi-like
#   commands to navigate and edit.
#
# Once this is set, you'll use vi-like commands for command line editing,
# such as `h`, `j`, `k`, `l` for movement, `i` to enter insert mode,
# `Esc` to go back to command mode, etc.
# ------------------------------------------

bindkey "^X" history-incremental-search-backward
# ------------------------------------------
# - `"^X"`: This is the representation for the Ctrl+X key combination.
#
# - `history-incremental-search-backward`: This is a zsh widget (a command that can be
#   bound to a key). When invoked, it allows you to search backward through your
#   command history incrementally. As you type, it will display the most recent
#   command that matches the characters you've entered so far.
#
# By using this `bindkey` command, you're binding the Ctrl+R key combination to the
# functionality of incrementally searching backward through your command history.
# This provides a quick way to recall and reuse previously entered commands.
# ------------------------------------------

bindkey "^[[Z" reverse-menu-complete
# ------------------------------------------
# - `"^[[Z"`: This is a key sequence representing the "Shift+Tab" key combination in many
#   terminal emulators.
#
# - `reverse-menu-complete`: This is the action/command being bound to the key sequence.
#   It triggers the completion system to cycle through possible matches in reverse order.
#
# By executing this command, you're configuring zsh to cycle backward through completion
# options when you press the "Shift+Tab" key combination. This is especially useful when
# you've gone past the desired completion with "Tab" and want to go back without cycling
# through all the options again.
# ------------------------------------------

# ------------------------------------------
# OPTIONS
#
# `setopt` in zsh is used to set shell options.
# `unsetopt` is used to unset (or disable) shell options.
# ------------------------------------------

setopt autocd
# ------------------------------------------
# - `autocd`: This is a specific zsh option that, when set, allows you to
#   change directories without needing to explicitly use the `cd` command.
#
# By enabling this option, you can simply type the name of a directory and
# press Enter to change into that directory, without having to prefix it with `cd`.
#
# For example, instead of typing `cd Documents`, you can just type `Documents`
# and press Enter to navigate into the Documents directory.
# ------------------------------------------

setopt autopushd
# ------------------------------------------
# - `autopushd`: This is a specific zsh option that, when set, automatically
#   pushes the current directory onto the directory stack when you use the `cd`
#   command. This allows for easy navigation between directories using `pushd`
#   and `popd`.
#
# By enabling this option, every time you change the directory with `cd`, the
# directory you just left gets added to the stack. You can then use `popd` to
# return to it, essentially treating the directory navigation like a stack-based
# history. This provides a more efficient way to move back and forth between
# a series of directories.
# ------------------------------------------

setopt dotglob
# ------------------------------------------
# - `dotglob`: This option affects the behavior of filename pattern matching.
#
# By enabling the `dotglob` option with `setopt`, you're instructing zsh to treat
# filenames starting with a dot (often called "dot files" or "hidden files") as
# regular matches when using filename patterns (like `*`).
#
# For instance, without `dotglob`, the pattern `*` would not match files like `.gitignore`.
# With `dotglob` set, the pattern `*` would include `.gitignore` and other hidden files
# in its matches.
# ------------------------------------------

setopt hist_fcntl_lock
# ------------------------------------------
# - `hist_fcntl_lock`: This is a specific zsh option that causes the shell to use
#   a file control lock (`fcntl()`) on the history file for the duration of each
#   history file access. The purpose of this lock is to prevent potential issues
#   with simultaneous access to the history file, which might happen if you have
#   multiple zsh instances running concurrently.
#
# By setting this option, you're adding an extra layer of safety to
# prevent history file corruption or unexpected behaviors when multiple zsh
# sessions are trying to write to the history file simultaneously.
# ------------------------------------------

setopt hist_ignore_dups
# ------------------------------------------
# - `hist_ignore_dups`: This is a specific zsh option that, when set, prevents
#   consecutive duplicate commands from being stored in the history.
#
# By enabling this option, if you run the same command multiple times consecutively,
# only the first instance will be saved to the history. This can be useful to
# keep your history clean and free from clutter, especially when repeating a
# command several times in a row.
# ------------------------------------------

setopt hist_ignore_space
# ------------------------------------------
# - `hist_ignore_space`: This is a specific zsh option that, when set, prevents
#   commands that start with a space from being stored in the history.
#
# By enabling this option, any command you enter that starts with a space will
# not be recorded in the command history. This can be useful when entering
# sensitive or temporary commands that you don't want to be logged in the history.
# ------------------------------------------

unsetopt hist_expire_dups_first
# ------------------------------------------
# - `hist_expire_dups_first`: This specific zsh option, when set, ensures that
#   when the history is trimmed (because it has reached its maximum length defined by
#   $HISTSIZE), duplicate entries will be removed before unique ones.
#
# By using `unsetopt` with this option, you are disabling this behavior, meaning
# that when the history is trimmed, entries will be removed based on their age
# (the oldest commands are removed first) without specifically targeting duplicates.
# ------------------------------------------

unsetopt share_history
# ------------------------------------------
# - `share_history`: This is a specific zsh option that, when set, enables the
#   sharing of command history across all active zsh sessions.
#
# By enabling this option, every time you enter a command in one zsh session,
# the command gets appended to the history file. When you access another zsh
# session, it will read the history file and update its in-memory history,
# effectively sharing the history across multiple sessions.
#
# This can be useful if you have multiple terminal windows or sessions open
# and want a unified command history across all of them.
# ------------------------------------------

unsetopt extended_history
# ------------------------------------------
# - `extended_history`: This specific zsh option, when set, records both the
#   command and the timestamp of when it was executed to the history.
#
# By using `unsetopt` with this option, you are disabling the recording of
# timestamps in the history. Therefore, only the commands themselves will be
# stored without any additional information about when they were executed.
# ------------------------------------------

setopt inc_append_history
# ------------------------------------------
# - `inc_append_history`: This is a specific zsh option that, when set, will
#   immediately append each command executed to the history file ($HISTFILE)
#   rather than waiting until the shell exits.
#
# By enabling this option, commands are saved to the history file as soon as
# they are executed. This behavior is particularly useful if you have multiple
# zsh sessions open at once and want them to share a unified command history
# in real-time, ensuring that commands executed in one session are immediately
# available in the history of other sessions.
# ------------------------------------------

setopt null_glob
# ------------------------------------------
# - `null_glob`: This is a specific zsh option that, when set, changes the behavior
#   of the shell when a wildcard pattern does not match any filenames.
#
# By default, if you try to use a wildcard pattern that doesn't match any files,
# zsh will throw an error. However, when the `null_glob` option is enabled, zsh
# will simply remove the pattern from the command line arguments and continue
# executing the command without an error.
#
# For example, without `null_glob`:
# `rm *.bak` will give an error if no `.bak` files exist.
#
# With `null_glob` enabled:
# `rm *.bak` will just do nothing if no `.bak` files exist.
# ------------------------------------------

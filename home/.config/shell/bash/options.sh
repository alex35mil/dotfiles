set -o vi
# ------------------------------------------
# Explanation:
# - `set -o`: In Bash, this command is used to control various shell options.
#
# - `vi`: When you specify `set -o vi`, you're setting the command-line editing mode
#   to use vi keybindings in Bash.
#
# Once this is set, the command-line interface will operate in a manner similar to
# the vi editor. For example, you will start in "normal mode" (where you can use
# commands like `h`, `j`, `k`, and `l` for movement), and you can press `i` to
# enter "insert mode" and make modifications. Pressing `Esc` will take you back
# to normal mode.
# ------------------------------------------

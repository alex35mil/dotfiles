alias bs="brew search "

bi() {
    if [ $# -eq 0 ]; then
        echo "Error: No package specified"
        echo "Usage: bi <package-name> [additional-packages...]"
        return 1
    fi

    echo "Installing: $*"
    if brew install "$@"; then
        echo "✅ Installation successful, updating Brewfile..."
        brew bundle dump --force --no-vscode
        echo "✅ Brewfile updated"
    else
        echo "❌ Installation failed, Brewfile not updated"
        return 1
    fi
}

brm() {
    if [ $# -eq 0 ]; then
        echo "Error: No package specified"
        echo "Usage: brm <package-name> [additional-packages...]"
        return 1
    fi

    echo "Uninstalling: $*"
    if brew uninstall "$@"; then
        echo "✅ Uninstall successful, updating Brewfile..."
        brew bundle dump --force --no-vscode
        echo "✅ Brewfile updated"
    else
        echo "❌ Uninstall failed, Brewfile not updated"
        return 1
    fi
}

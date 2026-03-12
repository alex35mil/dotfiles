alias bs="brew search "

bup() {
    brew bundle dump --force \
        --file "$HOMEBREW_BUNDLE_FILE" \
        --no-vscode \
        --no-go \
        --no-cargo \
        --no-uv \
        --no-flatpak
}

bi() {
    if [ $# -eq 0 ]; then
        echo "Error: No package specified"
        echo "Usage: bi <package-name> [additional-packages...]"
        return 1
    fi

    echo "Installing: $*"
    if brew install "$@"; then
        echo "✅ Installation successful, updating Brewfile..."
        if bup; then
            echo "✅ Brewfile updated"
        else
            echo "❌ Brewfile update failed"
            return 1
        fi
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
        if bup; then
            echo "✅ Brewfile updated"
        else
            echo "❌ Brewfile update failed"
            return 1
        fi
    else
        echo "❌ Uninstall failed, Brewfile not updated"
        return 1
    fi
}

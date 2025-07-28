# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing configuration files for a development environment centered around:
- **Terminal**: Ghostty (previously Alacritty) with Zellij multiplexer
- **Shell**: Zsh with custom configuration
- **Editor**: Neovim with extensive Lua configuration
- **Package Management**: Homebrew + Mise for runtime management

## Architecture

### Directory Structure
- `home/` - Contains all dotfiles that get symlinked to `$HOME`
- `bin/` - Custom Rust binaries (Zellij runner and statusbar)
- `script/` - Installation and maintenance scripts
- `home/.config/` - Main configuration directory with app-specific configs

### Key Components

#### Shell Configuration (`home/.config/shell/`)
- `init.sh` - Main shell initialization script
- `variables.sh` - Environment variables
- `shortcuts.sh` - Custom aliases and functions
- `apps/` - App-specific configuration (git, zellij, node, etc.)
- `zsh/` - Zsh-specific options and completions

#### Neovim Configuration (`home/.config/nvim/`)
- `init.lua` - Entry point loading utils, theme, screen, keymaps, editor, options, and plugins
- `lua/editor/` - Core editor functionality modules
- `lua/plugins/` - Plugin configurations
- `lua/theme/` - Custom theme implementation
- `lua/keymaps.lua` - Keymaps helpers
- `lua/options.lua` - Neovim and Neovide options
- `lua/plugins.lua` - Lazy plugin manager config

#### Zellij Configuration (`home/.config/zellij/`)
- `config.kdl` - Main Zellij configuration with custom keybindings
- `layouts/` - Session layouts (terminal, psc)
- `themes/` - Custom themes
- Custom keybindings use Unicode symbols mapped in terminal config

## Development Commands

### Installation
```bash
# Install dotfiles and build binaries
script/install.sh

# Build only Zellij statusbar
cd bin/zellij/statusbar && cargo build --release

# Build only Zellij runner
cd bin/zellij/runner && cargo install --locked --path .
```

### Rust Binaries
```bash
# Build Zellij statusbar (WASM plugin)
cd bin/zellij/statusbar
cargo build --release
# Output: target/wasm32-wasip1/release/statusbar.wasm

# Build Zellij runner (session switcher)
cd bin/zellij/runner
cargo build --release
# Install: cargo install --locked --path .
```

### Font Management
```bash
# Patch Berkeley Mono with Nerd Font icons
script/font/patch.sh
```

## Development Workflow

### Making Changes
1. Edit files in `home/.config/` directories
2. Changes are automatically available (files are symlinked)
3. For shell changes, restart terminal or run `exec zsh`
4. For Neovim changes, restart Neovim or reload configuration

### Zellij Usage
- Session management via `zellij-runner` command
- Custom keybindings use Unicode symbols (see `config.kdl`)
- Layouts stored in `layouts/` directory
- Custom statusbar plugin built from `bin/zellij/statusbar/`

### Neovim Development
- Plugin management via Lazy.nvim
- Custom theme in `lua/theme/`
- Editor functionality split into modules in `lua/editor/`
- Language-specific configurations in `lua/plugins/languages/`

## Important Notes

### Shell Environment
- Uses Mise for language runtime management
- Homebrew for package management
- Custom shortcuts and aliases in `shortcuts.sh`
- Environment variables in `variables.sh`

### Zellij Keybindings
- Custom keybindings use Unicode symbols mapped in Ghostty config
- Requires specific terminal configuration for proper operation
- Keybindings cleared and replaced with custom mappings

### Neovim Architecture
- Modular structure with clear separation of concerns
- Custom utilities in `lua/utils/`
- Screen-specific configurations in `lua/screen.lua`
- Type definitions in `lua/types.lua`

## Testing

No formal test suite. Verify changes by:
- Restarting affected applications
- Testing key functionality manually
- Checking for syntax errors in configuration files

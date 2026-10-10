# dotfiles

My terminal setup (WezTerm, fish, Starship, git, SSH), identical on macOS, Windows and WSL. Managed with [chezmoi](https://www.chezmoi.io). Feel free to use it: `chezmoi init` asks for your own name and email.

## What's inside

| File in `home/` | Installed as | Systems |
|---|---|---|
| `dot_wezterm.lua` | `~/.wezterm.lua` | macOS, Windows |
| `dot_config/fish/config.fish.tmpl` | `~/.config/fish/config.fish` | macOS, Linux/WSL |
| `dot_config/starship.toml.tmpl` | `~/.config/starship.toml` | all (badge `mac` / `win` / `wsl`) |
| `dot_bashrc`, `dot_inputrc` | `~/.bashrc`, `~/.inputrc` | Linux/WSL |
| `dot_config/git/config.tmpl`, `dot_config/git/ignore` | `~/.config/git/config`, `~/.config/git/ignore` (your own `~/.gitconfig` is left alone, and wins) | all |
| `private_dot_ssh/modify_private_config` | **adds** `Include config.d/*` at the top of `~/.ssh/config`, keeps the rest | all |
| `private_dot_ssh/private_config.d/private_github` | `~/.ssh/config.d/github` (which key to use for GitHub) | macOS, Linux/WSL |
| `Documents/…/Microsoft.PowerShell_profile.ps1` | PowerShell 7 and 5.1 profiles | Windows |
| `AppData/…/WindowsTerminal…/settings.json` | Windows Terminal (fallback) | Windows |
| `.chezmoidata/packages.yaml` | package lists (Homebrew, winget) | all |
| `.chezmoiscripts/` | install those packages when the lists change, and on Windows the latest JetBrainsMono Nerd Font from GitHub (winget's is too old for some icons) | all |
| `scripts/wsl-root-setup.sh` | the `sudo` part of a fresh WSL (apt, Docker, gh, fish) | WSL, run by hand |

Never in the repo: SSH keys, servers, `.env` files, tokens. Each machine generates its own SSH key, and personal servers go in `~/.ssh/config.d/` (picked up by the `Include` line).

## Day to day

- **Change a setting**: edit the file in `home/`, then `chezmoi apply`. Or `chezmoi edit ~/.wezterm.lua`, which opens the right source file.
- **See what would change**: `chezmoi diff`.
- **Share it**: `git commit` and `git push` in the repo.
- **Update another machine**: `chezmoi update` (pulls, applies, and installs new packages).
- **Add a tool**: add it to `home/.chezmoidata/packages.yaml`, then `chezmoi apply`.

## Set up a new machine

### macOS
1. Install Homebrew: https://brew.sh
2. `brew install chezmoi`, then `chezmoi init martinctl`
3. **Before applying**, run `chezmoi diff`: an existing `~/.config/fish/config.fish` would be replaced (SSH and git configs are only added to). Keep a copy, and move anything machine-specific to `~/.config/fish/conf.d/local.fish`, which fish loads by itself and the repo never touches.
4. `chezmoi apply` (installs fish, Starship, WezTerm and the font), then switch to fish: add `$(brew --prefix)/bin/fish` to `/etc/shells` and run `chsh -s $(brew --prefix)/bin/fish`.

### Windows (+ WSL)
1. Windows: `winget install twpayne.chezmoi`, then `chezmoi init --apply https://github.com/martinctl/dotfiles.git`. The winget packages install themselves.
2. WSL: `wsl --install -d Ubuntu-24.04`, create the user.
3. In Ubuntu: create a GitHub key (`ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github`), add it to GitHub, clone this repo into `~/dev/dotfiles`.
4. `sudo bash ~/dev/dotfiles/scripts/wsl-root-setup.sh`, then install Homebrew: `NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`.
5. `/home/linuxbrew/.linuxbrew/bin/brew install chezmoi`, then `chezmoi init --apply --source ~/dev/dotfiles`.
6. Run `wsl-root-setup.sh` again so that fish becomes the login shell.
7. Optional: point Windows' chezmoi at the same source, `chezmoi init --apply --source \\wsl.localhost\Ubuntu-24.04\home\<user>\dev\dotfiles`, so there is a single copy of the repo.

## Terminal shortcuts (WezTerm)

Cmd on macOS = Ctrl on Windows, except for moving between panes, which uses the key next to the space bar (Cmd ↔ Alt). Native text navigation is untouched (Option/Cmd+arrows on macOS, Ctrl+arrows on Windows).

| Action | macOS | Windows |
|---|---|---|
| Split in a direction | Cmd+Alt+arrow | Ctrl+Alt+arrow |
| Move between panes | Cmd+Shift+arrow | Alt+Shift+arrow |
| Zoom the pane in/out | Cmd+Z | Ctrl+Shift+Z |
| Close the pane | Cmd+W | Ctrl+Shift+W |
| New tab | Cmd+T | Ctrl+Shift+T |
| Go to tab n | Cmd+1…9 | Ctrl+1…9 |
| Launcher (WSL / PowerShell) | — | Ctrl+Shift+N |
| Copy / paste | Cmd+C / Cmd+V | Ctrl+C (with a selection) / Ctrl+V |
| New line without sending (Claude Code) | Shift+Enter | Shift+Enter |

Shell (fish, and PowerShell set up the same way): the greyed-out suggestion comes from history, → accepts it, Tab completes, ↑/↓ search the commands that start the same way.

## Command-line tools

| Tool | What it does | How to use it |
|---|---|---|
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Remembers the folders you visit and jumps back to them | `z track` → `~/dev/trackimo`; `z track serv` → `~/dev/trackimo/trackimo-service` (several words narrow it down); `z -` → previous folder; `zi` → pick from a list. It learns as you move around with `cd` or `z`. |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder: type a few letters in any order, the list narrows as you type | `Ctrl+R` searches your whole history; `Ctrl+T` inserts a file path from the current folder; `Alt+C` jumps into a subfolder (on macOS: left Option+C). Both show a preview on the right. Also powers `zi`. In the list: ↑/↓ to move, Enter to pick, Esc to cancel. |
| [eza](https://github.com/eza-community/eza) | `ls` with colours, icons and git status | `ls` lists the folder; `ll` adds sizes, dates ("2 hours ago") and a git column (`M` modified, `N` new…); `la` also shows hidden files; `lt` shows a tree two levels deep. |
| [bat](https://github.com/sharkdp/bat) | `cat` with syntax highlighting, line numbers and git changes in the margin | `cat file` shows it highlighted; `bat file` does the same in a scrollable view (q to quit). Its theme follows the terminal's light/dark mode. It also draws the file preview in fzf's `Ctrl+T`. |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Searches **inside** files, very fast, skipping what `.gitignore` excludes (node_modules, builds…) | `rg TkIcon` lists every line that mentions it, with the file and line number; `rg -l TkIcon` only the files; `rg TkIcon -t vue` only `.vue` files; `rg -w id` whole words only. Lowercase searches ignore case, a capital letter makes it exact. |
| [fd](https://github.com/sharkdp/fd) | Finds files **by name**, very fast, skipping what `.gitignore` excludes | `fd objectives` finds `components/game/Objectives.vue`; `fd -e svg` all SVG files; `fd -t d icons` only folders. It also feeds fzf's `Ctrl+T` and `Alt+C`, so they no longer list node_modules. |

## To add later

mise (language versions per project), lazygit and delta (git), atuin (shared history, optional).

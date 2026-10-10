# Managed by chezmoi: edit it in the dotfiles repo, then run `chezmoi apply`.

# fnm: makes node/npm available and switches version from the folder's .nvmrc / .node-version
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
}

# PSReadLine, set up like fish: one greyed-out suggestion from history,
# → accepts it, Ctrl+→ takes one word of it, Tab opens the completion menu.
if (-not [Console]::IsOutputRedirected) {
    Set-PSReadLineOption -PredictionSource History -PredictionViewStyle InlineView
}
Set-PSReadLineOption -HistorySearchCursorMovesToEnd -BellStyle None
Set-PSReadLineKeyHandler -Key RightArrow -Function ForwardChar
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Starship: the prompt (config in ~/.config/starship.toml)
Invoke-Expression (&starship init powershell)

# zoxide: `z <part of a name>` jumps to a folder you've been to, `zi` picks from a list
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# fzf: Ctrl+R searches history, Ctrl+T inserts a file path (through the PSFzf module)
$env:FZF_DEFAULT_OPTS = '--height=40% --layout=reverse --border --color=16'
$env:FZF_CTRL_T_OPTS = "--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
# fd lists the candidates: fast, and skips node_modules and anything in .gitignore
if (Get-Command fd -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git'
    $env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
}

# ripgrep: defaults in ~/.config/ripgrep/config (smart case, hidden files, never .git)
$env:RIPGREP_CONFIG_PATH = Join-Path $HOME '.config\ripgrep\config'
if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Module -ListAvailable -Name PSFzf)) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# eza: ls with colours, icons and git status (replaces PowerShell's own `ls` alias)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    function ls { eza --icons=auto --group-directories-first @args }
    function ll { eza -l --git --icons=auto --group-directories-first --time-style=relative @args }
    function la { eza -la --git --icons=auto --group-directories-first --time-style=relative @args }
    function lt { eza --tree --level=2 --icons=auto --group-directories-first @args }
}

# bat: cat with syntax highlighting (theme follows the terminal's light/dark mode)
$env:BAT_THEME_DARK = 'Monokai Extended'
$env:BAT_THEME_LIGHT = 'GitHub'
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    function cat { bat --paging=never @args }
}

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
if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Module -ListAvailable -Name PSFzf)) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# Managed by chezmoi. Legacy Windows PowerShell 5.1: the bare minimum (PowerShell 7 is the real one).
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
}
Invoke-Expression (&starship init powershell)

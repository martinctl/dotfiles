-- Managed by chezmoi: edit it in the dotfiles repo, then run `chezmoi apply`.
-- One config for macOS and Windows: same shortcuts, same look.
local wezterm = require('wezterm')
local act = wezterm.action
local config = wezterm.config_builder()

local is_mac = wezterm.target_triple:find('darwin') ~= nil
local is_windows = wezterm.target_triple:find('windows') ~= nil

-- The "main" modifier: Cmd on macOS, Ctrl on Windows/Linux.
local MOD = is_mac and 'CMD' or 'CTRL'
-- For shortcuts where Ctrl alone would clash with the shell (Ctrl+W, Ctrl+T…), PCs use Ctrl+Shift.
local MOD_SAFE = is_mac and 'CMD' or 'CTRL|SHIFT'

------------------------------------------------------------------------------
-- Look: black background, Campbell palette (the Windows Terminal default)
------------------------------------------------------------------------------
config.font = wezterm.font_with_fallback({ 'JetBrainsMono Nerd Font', 'JetBrains Mono' })
config.font_size = is_mac and 14 or 11
config.colors = {
  background = '#0C0C0C',
  foreground = '#CCCCCC',
  cursor_bg = '#FFFFFF',
  cursor_fg = '#0C0C0C',
  cursor_border = '#FFFFFF',
  selection_bg = '#FFFFFF',
  selection_fg = '#0C0C0C',
  ansi = { '#0C0C0C', '#C50F1F', '#13A10E', '#C19C00', '#0037DA', '#881798', '#3A96DD', '#CCCCCC' },
  brights = { '#767676', '#E74856', '#16C60C', '#F9F1A5', '#3B78FF', '#B4009E', '#61D6D6', '#F2F2F2' },
  tab_bar = { background = '#0C0C0C' },
}
config.initial_cols = 100
config.initial_rows = 25
config.window_padding = { left = 6, right = 6, top = 4, bottom = 4 }
config.audible_bell = 'Disabled'
config.use_fancy_tab_bar = false
config.tab_max_width = 32

------------------------------------------------------------------------------
-- Windows: open straight into WSL; PowerShell stays one shortcut away
------------------------------------------------------------------------------
if is_windows then
  config.default_prog = { 'pwsh.exe', '-NoLogo' } -- program of the Windows ("local") domain
  config.launch_menu = {
    { label = 'PowerShell', domain = { DomainName = 'local' }, args = { 'pwsh.exe', '-NoLogo' } },
  }
  -- First WSL distribution found (Ubuntu preferred) becomes the default
  local wsl_domains = wezterm.default_wsl_domains()
  table.sort(wsl_domains, function(a, b)
    return (a.distribution or ''):find('^Ubuntu') ~= nil and (b.distribution or ''):find('^Ubuntu') == nil
  end)
  if #wsl_domains > 0 then
    config.default_domain = wsl_domains[1].name
    for _, d in ipairs(wsl_domains) do
      table.insert(config.launch_menu, { label = d.distribution .. ' (WSL)', domain = { DomainName = d.name } })
    end
  end
end

------------------------------------------------------------------------------
-- Tabs tinted by system: orange = WSL, blue = Windows, grey = macOS
------------------------------------------------------------------------------
wezterm.on('format-tab-title', function(tab, _, _, _, _, max_width)
  local pane = tab.active_pane
  local is_wsl = pane.domain_name:find('^WSL:') ~= nil
  local tint = is_wsl and '#7A3A1E' or (is_windows and '#24456E' or '#3A3A3A')
  local dim = is_wsl and '#C9875F' or (is_windows and '#8FA9CC' or '#9A9A9A')
  local title = tab.tab_title ~= '' and tab.tab_title or pane.title
  title = wezterm.truncate_right(title, max_width - 6)
  return {
    { Background = { Color = tab.is_active and tint or '#161616' } },
    { Foreground = { Color = tab.is_active and '#FFFFFF' or dim } },
    { Text = ' ' .. (tab.tab_index + 1) .. ' ' .. title .. ' ' },
  }
end)

------------------------------------------------------------------------------
-- Shortcuts: the same on macOS and Windows, with Cmd <-> Ctrl.
-- Native text navigation is left alone (Option/Cmd+arrows on macOS, Ctrl+arrows on Windows).
------------------------------------------------------------------------------
config.keys = {
  -- Shift+Enter: new line without sending (Claude Code)
  { key = 'Enter', mods = 'SHIFT', action = act.SendString('\x1b\r') },

  -- Split: Cmd/Ctrl + Alt + arrow, in the arrow's direction
  { key = 'LeftArrow', mods = MOD .. '|ALT', action = act.SplitPane({ direction = 'Left' }) },
  { key = 'RightArrow', mods = MOD .. '|ALT', action = act.SplitPane({ direction = 'Right' }) },
  { key = 'UpArrow', mods = MOD .. '|ALT', action = act.SplitPane({ direction = 'Up' }) },
  { key = 'DownArrow', mods = MOD .. '|ALT', action = act.SplitPane({ direction = 'Down' }) },

  -- Move between panes: Cmd/Ctrl + Shift + arrow
  { key = 'LeftArrow', mods = MOD .. '|SHIFT', action = act.ActivatePaneDirection('Left') },
  { key = 'RightArrow', mods = MOD .. '|SHIFT', action = act.ActivatePaneDirection('Right') },
  { key = 'UpArrow', mods = MOD .. '|SHIFT', action = act.ActivatePaneDirection('Up') },
  { key = 'DownArrow', mods = MOD .. '|SHIFT', action = act.ActivatePaneDirection('Down') },

  -- Close the pane (Cmd+W / Ctrl+Shift+W); zoom the pane in and out (Cmd+Z / Ctrl+Shift+Z)
  { key = 'w', mods = MOD_SAFE, action = act.CloseCurrentPane({ confirm = false }) },
  { key = 'z', mods = MOD_SAFE, action = act.TogglePaneZoomState },

  -- New tab: Cmd+T / Ctrl+Shift+T
  { key = 't', mods = MOD_SAFE, action = act.SpawnTab('CurrentPaneDomain') },

  -- Launcher (WSL distributions / PowerShell): Cmd+Shift+N / Ctrl+Shift+N
  { key = 'n', mods = MOD .. '|SHIFT', action = act.ShowLauncherArgs({ flags = 'LAUNCH_MENU_ITEMS' }) },
}

-- Go to tab n: Cmd+1…9 / Ctrl+1…9 (physical key, so it also works on AZERTY keyboards)
for i = 1, 9 do
  table.insert(config.keys, { key = 'phys:' .. i, mods = MOD, action = act.ActivateTab(i - 1) })
end

-- Windows/Linux: Ctrl+C copies when there is a selection (otherwise it interrupts as usual), Ctrl+V pastes
if not is_mac then
  table.insert(config.keys, {
    key = 'c',
    mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
      if window:get_selection_text_for_pane(pane) ~= '' then
        window:perform_action(act.CopyTo('Clipboard'), pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act.SendKey({ key = 'c', mods = 'CTRL' }), pane)
      end
    end),
  })
  table.insert(config.keys, { key = 'v', mods = 'CTRL', action = act.PasteFrom('Clipboard') })
end

return config

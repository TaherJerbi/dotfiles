-- Devpod-only (chezmoi skips this file on other hosts): the pod has no
-- clipboard provider, so `"+y` would drop yanks. Use nvim's native OSC 52,
-- written by the TUI itself, which reaches the browser through ttyd.
-- osc52copy.sh can't stand in here: nvim captures a copy job's stdout and gives
-- it no controlling TTY, so its OSC 52 never reaches the terminal.
local copy = { ['+'] = require('vim.ui.clipboard.osc52').copy '+', ['*'] = require('vim.ui.clipboard.osc52').copy '*' }
vim.g.clipboard = {
  name = 'osc52-ttyd',
  copy = copy,
  paste = {
    ['+'] = function() return { vim.fn.split(vim.fn.getreg '', '\n'), vim.fn.getregtype '' } end,
    ['*'] = function() return { vim.fn.split(vim.fn.getreg '', '\n'), vim.fn.getregtype '' } end,
  },
}

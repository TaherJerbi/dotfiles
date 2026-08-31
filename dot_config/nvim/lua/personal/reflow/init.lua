-- Reflowed yank: pipe text through reflow.py, which undoes the cosmetic line
-- breaks markdown linters/prettier insert mid-sentence, and put the result on
-- the system clipboard. Mapped to <leader>ry in personal/init.lua.

local M = {}

local script = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'personal', 'reflow', 'reflow.py')

-- Reflow is a whole-line operation, so both entry points round out to line bounds.
local function yank(first, last)
  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  local reflowed = vim.fn.systemlist({ 'python3', script }, lines)
  if vim.v.shell_error ~= 0 then
    vim.notify('reflow.py failed: ' .. table.concat(reflowed, '\n'), vim.log.levels.ERROR)
    return
  end
  vim.fn.setreg('+', reflowed, 'l')
  vim.notify(('Yanked %d reflowed line%s to clipboard'):format(#reflowed, #reflowed == 1 and '' or 's'))
end

-- Called while still in visual mode, so read the live selection ends rather
-- than the '< and '> marks (which only update on leaving visual mode).
function M.visual()
  local a, b = vim.fn.line 'v', vim.fn.line '.'
  yank(math.min(a, b), math.max(a, b))
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
end

function M.operator()
  yank(vim.fn.line "'[", vim.fn.line "']")
end

return M

-- Non-LSP CLI tools that mason won't install just from vim.lsp.enable.
-- ensure_installed lives in the base config's mason-tool-installer.setup(), which
-- would clobber rather than merge if called again here, so install directly instead.
local tools = { 'stylua', 'black', 'flake8', 'prettierd' }

local ok, registry = pcall(require, 'mason-registry')
if ok then
  registry.refresh(function()
    for _, name in ipairs(tools) do
      local pkg_ok, pkg = pcall(registry.get_package, name)
      if pkg_ok and not pkg:is_installed() then pkg:install() end
    end
  end)
end

-- Turn on format-on-save and wire up formatters kickstart leaves unconfigured.
require('conform').setup {
  notify_on_error = true,
  default_format_opts = { lsp_format = 'fallback' },
  format_on_save = function(bufnr)
    local disable_filetypes = { c = true, cpp = true }
    if disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    else
      return { timeout_ms = 500 }
    end
  end,
  formatters = {
    black = { prepend_args = { '--line-length=100' } },
  },
  formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'black' },
    javascript = { 'prettierd' },
    javascriptreact = { 'prettierd' },
    typescript = { 'prettierd' },
    typescriptreact = { 'prettierd' },
    json = { 'prettierd' },
    jsonc = { 'prettierd' },
    yaml = { 'prettierd' },
    css = { 'prettierd' },
    html = { 'prettierd' },
    markdown = { 'prettierd' },
  },
}

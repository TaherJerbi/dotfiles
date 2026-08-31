-- Extra language servers on top of kickstart's lua_ls-only default.
-- mason-lspconfig.setup() (called in the base config) auto-installs any
-- server enabled via vim.lsp.enable, so no manual :MasonInstall needed.
local servers = { 'pyright', 'ts_ls', 'eslint', 'jsonls', 'yamlls', 'bashls' }

for _, name in ipairs(servers) do
  vim.lsp.config(name, {})
  vim.lsp.enable(name)
end

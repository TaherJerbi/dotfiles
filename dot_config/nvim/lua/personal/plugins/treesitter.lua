-- Extra parsers on top of kickstart's default set. install() is additive,
-- so this doesn't need to touch the base config's parser list.
require('nvim-treesitter').install {
  'python',
  'typescript',
  'tsx',
  'javascript',
  'json',
  'yaml',
  'css',
}

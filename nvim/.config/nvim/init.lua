-- Set colorscheme
vim.cmd("colorscheme lunaperche") 

-- Set indentation
vim.opt.shiftwidth = 2  

-- Show statusline
vim.opt.laststatus = 2  

-- Highlight search results
vim.opt.hlsearch = true 

-- Incremental search
vim.opt.incsearch = true  

-- Enhanced command-line completion
vim.opt.wildmenu = true  

-- Custom statusline
vim.opt.statusline = "%F %h%m%r %=FileType:%Y Encoding:%{&fileencoding} Line:%l/%L Col:%c"


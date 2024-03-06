-- Create an augroup to group related autocommands. This prevents duplicating autocommands every time you source your config.
vim.api.nvim_create_augroup('CMakeFormatting', { clear = true })

-- Add an autocommand to the group
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'cmake',  -- Neovim recognizes CMakeLists.txt files as filetype 'cmake'
    group = 'CMakeFormatting',
    callback = function()
        -- Check if the file name is exactly 'CMakeLists.txt'
        if vim.fn.expand('%:t') == 'CMakeLists.txt' then
            vim.opt_local.tabstop = 4
            vim.opt_local.shiftwidth = 4
        end
    end,
})

local function get_python_path()
  local handle = io.popen("which python")
  local result = handle:read("*a")
  handle:close()
  return result:gsub("%s+", "") -- Remove any trailing whitespace
end

local M = {}

-- Check "pyright fix macos" in obsidian
function M.get_pyright_settings()
  local uname = vim.loop.os_uname().sysname
  local is_mac = uname == 'Darwin'

  if is_mac then
    return {python = {pythonPath = get_python_path()}}
  else
    return {}
  end
end

return M

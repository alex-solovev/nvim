local M = {}

local save_path = vim.fn.stdpath("data") .. "/pins"

local context = {
  focused_index = 1,
  pins = {},
}

local function current_branch()
  local result = vim
    .system({
      "git",
      "branch",
      "--show-current",
    })
    :wait()

  if result.code ~= 0 then
    return nil
  end

  return result.stdout:gsub("%s+$", "")
end

local function save_context(path, project_path, branch, pins)
  local existing_file_saved_lines = {}
  local line_parts = { project_path, branch }
  for _, pin in ipairs(pins) do
    table.insert(line_parts, pin)
  end

  local file = io.open(path, "r")
  if file then
    for line in file:lines() do
      table.insert(existing_file_saved_lines, line)
    end

    file:close()
  end

  local wrote = false
  for i, line in ipairs(existing_file_saved_lines) do
    local line_fields = vim.split(line, "\t", { plain = true })
    if line_fields[1] == project_path and line_fields[2] == branch then
      existing_file_saved_lines[i] = table.concat(line_parts, "\t")
      wrote = true
    end
  end

  if not wrote then
    existing_file_saved_lines[#existing_file_saved_lines + 1] = table.concat(line_parts, "\t")
  end

  file = assert(io.open(path, "w"))
  for _, line in ipairs(existing_file_saved_lines) do
    file:write(line, "\n")
  end

  file:close()
end

local function load_context(path, project_path, branch)
  local file = io.open(path, "r")
  if not file then
    return
  end

  for line in file:lines() do
    local fields = vim.split(line, "\t", { plain = true })
    local data = {
      project_path = fields[1],
      branch = fields[2],
      pins = vim.list_slice(fields, 3),
    }

    if project_path == data.project_path and branch == data.branch then
      file:close()
      return data
    end
  end

  file:close()
end

local function create_floating_window(opts)
  opts = opts or {}

  local width = opts.width or math.floor(vim.o.columns * 0.5)
  local height = opts.height or math.floor(vim.o.lines * 0.25)

  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, context.pins)

  local win_config = {
    title = "Pins",
    title_pos = "center",
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    -- style = "minimal",
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, true, win_config)
  local group = vim.api.nvim_create_augroup("pins", { clear = false })
  vim.api.nvim_create_autocmd("WinLeave", {
    group = group,
    buffer = buf,
    callback = function()
      -- save_context(save_path, vim.fn.getcwd(), current_branch(), context.pins)
    end,
  })

  local function register_callback(key, fn)
    vim.keymap.set("n", key, fn, { buffer = buf, silent = true })
  end

  register_callback("<CR>", function()
    -- if #context.pins == 0 then
    -- 	return
    -- end
    local path = context.pins[context.focused_index]
    if not path then
      return
    end
    vim.api.nvim_win_close(win, false)
    vim.cmd.edit(vim.fn.fnameescape(path))
  end)

  register_callback("j", function()
    context.focused_index = math.min(context.focused_index + 1, #context.pins)
    vim.api.nvim_win_set_cursor(win, { context.focused_index, 0 })
  end)

  register_callback("k", function()
    context.focused_index = math.max(context.focused_index - 1, 1)
    vim.api.nvim_win_set_cursor(win, { context.focused_index, 0 })
  end)

  register_callback("<Esc>", function()
    context.pins = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    save_context(save_path, vim.fn.getcwd(), current_branch(), context.pins)
    vim.api.nvim_win_close(win, false)
  end)

  register_callback("q", function()
    context.pins = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    save_context(save_path, vim.fn.getcwd(), current_branch(), context.pins)
    vim.api.nvim_win_close(win, false)
  end)

  vim.api.nvim_set_current_win(win)

  return { buf = buf, win = win }
end

M.setup = function()
  vim.keymap.set("n", "ha", M.add)
  vim.keymap.set("n", "ho", M.open)
end

M.open = function()
  local data = load_context(save_path, vim.fn.getcwd(), current_branch())
  if data then
    context.pins = data.pins
    context.focused_index = 1
  end

  create_floating_window()
end

M.add = function()
  context.pins[#context.pins + 1] = vim.fn.expand("%:.")
  save_context(save_path, vim.fn.getcwd(), current_branch(), context.pins)
end

return M

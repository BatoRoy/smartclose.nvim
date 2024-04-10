local open = "({[<"
local closed = ")}]>"

function string.insert(str1, str2, pos)
    return str1:sub(1, pos) .. str2 .. str1:sub(pos + 1)
end

function RunSmartClose()
    print("Running")
    local current_line = vim.api.nvim_get_current_line()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    local stack = {}

    -- Define stack functions

    function stack.push(item)
        table.insert(stack, item)
    end

    function stack.pop()
        return table.remove(stack)
    end

    -- Search current line and add to stack.

    -- TODO: Check cursor pos when popping.     DONE!
    -- TODO: Move cursor if next char matches pop.
    -- TODO: Check if keybinding can be configured by user.
    -- TODO: Ignore if there is a break char before, ex: \ or %.    DONE!
    -- TODO: Check if closing maches open character.

    local pos = 1
    for c in current_line:gmatch("[%(%[{<%>}%]%)]") do
        local start_pos, end_pos = current_line:find(c, pos, true)
        local escape1_start_pos = current_line:find('\\', start_pos - 1, true)
        local escape2_start_pos = current_line:find('%', pos, true)
        
        if start_pos > col then
            break
        end

        if c == '(' or c == '{' or c == '[' or c == '<' then
        if start_pos > 1 and (escape1_start_pos == start_pos - 1 or escape2_start_pos == start_pos - 1) then
            -- Char before is an escape character.
        else
            stack.push(c)
        end
        elseif c == ')' or c == '}' or c == ']' or c == '>' then
            local popped = stack.pop()
        else
            -- print("Skipped ",c)
        end
        pos = end_pos + 1
    end

    -- Check final character

    local c_last = stack.pop()
    if c_last == nil then
        return
    end

    -- print("Last popped ", c_last)
    local c_insert = ""
    if c_last == "(" then
        c_insert = ")"
    elseif c_last == "[" then
        c_insert = "]"
    elseif c_last == "{" then
        c_insert = "}"
    elseif c_last == "<" then
        c_insert = ">"
    end

    -- Make new line.
    local new_line = string.insert(current_line, c_insert, col)
    -- Write line.
    vim.api.nvim_buf_set_lines(0, row - 1, row, true, { new_line })
    -- Move cursor.
    vim.api.nvim_win_set_cursor(0, { row, col + 1 })
end

-- Setup keybinding
vim.api.nvim_set_keymap("i", "<C-s>", "<cmd>lua RunSmartClose()<CR>", { noremap = true, silent = true })

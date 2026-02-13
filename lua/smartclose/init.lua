-- MIT License

-- Copyright (c) 2024 Adam Westergren


-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

function string.insert(str1, str2, pos)
    return str1:sub(1, pos) .. str2 .. str1:sub(pos + 1)
end

function _RemoveChar(stack, c)
    for i = #stack, 1, -1 do
        if stack[i] == c then
            table.remove(stack, i)
            return -- Remove only the first occurrence (from the end).
        end
    end
end

function _GetNextChar(current_line, col)
    local stack = {}
    -- Define stack functions.
    function stack.push(item)
        table.insert(stack, item)
    end

    function stack.pop()
        return table.remove(stack)
    end

    -- Search current line and add to stack.
    local normal_characters = "[%(%[{}%]%)\"'`]"

    local single_quote_opened = false
    local double_quote_opened = false
    local special_single_quote_opened = false
    local pos = 1

    for c in current_line:gmatch(normal_characters) do
        local start_pos, end_pos = current_line:find(c, pos, true)

        -- Ignore text after cursor.
        if start_pos > col then
            break
        end

        -- Check if character is escaped.
        local is_escaped = false
        if start_pos > 1 then
            local char_before = current_line:sub(start_pos - 1, start_pos - 1)
            if char_before == '\\' or char_before == '%' then
                is_escaped = true
            end
        end

        if not is_escaped then
            if c == '(' or c == '{' or c == '[' then
                stack.push(c)
            elseif c == ')' or c == '}' or c == ']' then
                stack.pop()
            else
                -- Handle quotes: "  ' `
                if c == '\'' then
                    if single_quote_opened then
                        _RemoveChar(stack, c)
                    else
                        stack.push(c)
                    end
                    single_quote_opened = not single_quote_opened
                elseif c == '\"' then
                    if double_quote_opened then
                        _RemoveChar(stack, c)
                    else
                        stack.push(c)
                    end
                    double_quote_opened = not double_quote_opened
                elseif c == '`' then
                    if special_single_quote_opened then
                        _RemoveChar(stack, c)
                    else
                        stack.push(c)
                    end
                    special_single_quote_opened = not special_single_quote_opened
                end
            end
        end
        pos = end_pos + 1
    end

    -- Check final character.
    local c_last = stack.pop()
    if c_last == nil then
        return
    end

    -- Pick char to insert.
    local c_insert = ""
    if c_last == "(" then
        c_insert = ")"
    elseif c_last == "[" then
        c_insert = "]"
    elseif c_last == "{" then
        c_insert = "}"
    elseif c_last == "\'" then
        c_insert = "\'"
    elseif c_last == "\"" then
        c_insert = "\""
    elseif c_last == "`" then
        c_insert = "`"
    end
    return c_insert
end

function RunSmartClose()
    local current_line = vim.api.nvim_get_current_line()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    local c_insert = _GetNextChar(current_line, col)
    if c_insert == nil or c_insert == "" then
        return
    end
    -- Make new line.
    local new_line = string.insert(current_line, c_insert, col)
    -- Write line.
    local next_c = string.sub(current_line, col + 1, col + 1)
    if c_insert ~= next_c then
        -- Will only insert char if the next char is not the same.
        vim.api.nvim_buf_set_lines(0, row - 1, row, true, { new_line })
    end
    -- Move cursor.
    vim.api.nvim_win_set_cursor(0, { row, col + 1 })
end

function _GetUnclosedStack(current_line, col)
    local stack = {}

    local matching_pairs = {
        ['('] = ')',
        ['{'] = '}',
        ['['] = ']',
    }

    local closing_pairs = {
        [')'] = '(',
        ['}'] = '{',
        [']'] = '[',
    }

    local quote_chars = {
        ['"'] = true,
        ["'"] = true,
        ['`'] = true
    }

    local single_open = false
    local double_open = false
    local backtick_open = false

    local pos = 1
    local pattern = "[%(%[{}%]%)\"'`]"

    for c in current_line:gmatch(pattern) do
        local start_pos, end_pos = current_line:find(c, pos, true)

        if start_pos > col then
            break
        end

        -- Check if character is escaped.
        local is_escaped = false
        if start_pos > 1 then
            local char_before = current_line:sub(start_pos - 1, start_pos - 1)
            if char_before == '\\' or char_before == '%' then
                is_escaped = true
            end
        end

        if not is_escaped then
            -- Handle brackets.
            if matching_pairs[c] then
                table.insert(stack, c)
            elseif closing_pairs[c] then
                if #stack > 0 and stack[#stack] == closing_pairs[c] then
                    table.remove(stack)
                end
                -- Handle quotes.
            elseif quote_chars[c] then
                if c == '"' then
                    if double_open then
                        if #stack > 0 and stack[#stack] == '"' then
                            table.remove(stack)
                        end
                    else
                        table.insert(stack, '"')
                    end
                    double_open = not double_open
                elseif c == "'" then
                    if single_open then
                        if #stack > 0 and stack[#stack] == "'" then
                            table.remove(stack)
                        end
                    else
                        table.insert(stack, "'")
                    end
                    single_open = not single_open
                elseif c == "`" then
                    if backtick_open then
                        if #stack > 0 and stack[#stack] == "`" then
                            table.remove(stack)
                        end
                    else
                        table.insert(stack, "`")
                    end
                    backtick_open = not backtick_open
                end
            end
        end

        pos = end_pos + 1
    end

    return stack
end

function RunSmartEnter()
    local current_line = vim.api.nvim_get_current_line()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- Character left and right of cursor.
    local char_before = string.sub(current_line, col, col)
    local char_after = string.sub(current_line, col + 1, col + 1)

    -- Opening delimiters and their matching closing delimiters.
    local matching_close = {
        ['('] = ')',
        ['{'] = '}',
        ['['] = ']',
        ['"'] = '"',
        ["'"] = "'",
        ['`'] = '`'
    }

    -- Check if we're between matching delimiters.
    local is_between_delimiters = false

    -- For brackets: opening before, closing after
    if (char_before == '(' and char_after == ')') or
        (char_before == '{' and char_after == '}') or
        (char_before == '[' and char_after == ']') then
        is_between_delimiters = true
    end

    -- For quotes and backticks: same character before and after.
    if (char_before == '"' or char_before == "'" or char_before == '`') and
        char_before == char_after then
        is_between_delimiters = true
    end

    -- Only continue if we're between matching delimiters.
    if not is_between_delimiters then
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes('<CR>', true, false, true),
            'n',
            false
        )
        return
    end

    local indent = current_line:match("^%s*") or ""
    local indent_char = vim.bo.expandtab and string.rep(" ", vim.bo.shiftwidth) or "\t"

    local line_before = string.sub(current_line, 1, col)
    local line_after = string.sub(current_line, col + 1)

    -- Get full unclosed stack.
    local stack = _GetUnclosedStack(current_line, col)

    if #stack == 0 then
        -- Fallback to normal enter.
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes('<CR>', true, false, true),
            'n',
            false
        )
        return
    end

    -- Build closing string (reverse order).
    local closing_line = indent

    for i = #stack, 1, -1 do
        local opener = stack[i]
        local closer = matching_close[opener]
        if closer then
            closing_line = closing_line .. closer
        end
    end

    local new_lines = {
        line_before,
        indent .. indent_char,
        closing_line .. line_after
    }

    vim.api.nvim_buf_set_lines(0, row - 1, row, true, new_lines)
    vim.api.nvim_win_set_cursor(0, { row + 1, #indent + #indent_char })
end

-- Set keybinding.
local function set_keymap(keymap)
    vim.api.nvim_set_keymap("i", keymap, "<cmd>lua RunSmartClose()<CR>", { noremap = true, silent = true })
end

local function set_enter_keymap()
    vim.api.nvim_set_keymap("i", "<CR>", "<cmd>lua RunSmartEnter()<CR>", { noremap = true, silent = true })
end

-- Setup plugin with default keymap.
local default_keymap = "<C-d>"
local function setup(opts)
    opts = opts or {}

    -- Set smart close keymap (use custom or default).
    local keymap = opts.keymap or default_keymap
    set_keymap(keymap)

    -- Enable smart enter by default unless explicitly disabled.
    if opts.enable_smart_enter ~= false then
        set_enter_keymap()
    end
end

-- Set custom keymap.
local function set_custom_keymap(keymap)
    set_keymap(keymap)
end

return {
    setup = setup,
    set_keymap = set_custom_keymap,
    set_enter_keymap = set_enter_keymap,
    _GetNextChar = _GetNextChar
}

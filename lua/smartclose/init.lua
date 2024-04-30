
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
    for i, value in ipairs(stack) do
        if value == c then
            table.remove(stack, i)
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

    local all_characters = "[%(%[{<%>}%]%)\"\']"
    local normal_characters = "[%(%[{}%]%)\"\']"

    local single_quote_opened = false
    local double_quote_opened = false
    local pos = 1
    for c in current_line:gmatch(normal_characters) do
        local start_pos, end_pos = current_line:find(c, pos, true)
        local escape1_start_pos = current_line:find('\\', start_pos - 1, true)
        local escape2_start_pos = current_line:find('%', pos, true)

        -- Ignore text after cursor.
        if start_pos > col then
            break
        end

        if start_pos < 1 or (escape1_start_pos ~= start_pos - 1 and escape2_start_pos ~= start_pos - 1) then
            if c == '(' or c == '{' or c == '[' or c == '<' then
                -- Char before is an escape character.
                stack.push(c)
            elseif c == ')' or c == '}' or c == ']' or c == '>' then
                stack.pop()
            else
                -- Handle " and '.
                if c == '\'' then
                    if single_quote_opened then
                        --stack.pop()
                        _RemoveChar(stack, c)
                    else
                        stack.push(c)
                    end
                    single_quote_opened = not single_quote_opened
                end
                if c == '\"' then
                    if double_quote_opened then
                        --stack.pop()
                        _RemoveChar(stack, c)
                    else
                        stack.push(c)
                    end
                    double_quote_opened = not double_quote_opened
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
    elseif c_last == "<" then
        c_insert = ">"
    elseif c_last == "\'" then
        c_insert = "\'"
    elseif c_last == "\"" then
        c_insert = "\""
    end
    return c_insert
end

function RunSmartClose()
    local current_line = vim.api.nvim_get_current_line()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    local c_insert = _GetNextChar(current_line, col)
    if c_insert == nil then
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

-- Set keybinding.
local function set_keymap(keymap)
    vim.api.nvim_set_keymap("i", keymap, "<cmd>lua RunSmartClose()<CR>", { noremap = true, silent = true })
end

-- Setup plugin with default keymap.
local default_keymap = "<C-s>"
local function setup()
    set_keymap(default_keymap)
end

-- Set custom keymap.
local function set_custom_keymap(keymap)
    set_keymap(keymap)
    print("Custom")
end

--setup()

return{
    set_keymap = set_custom_keymap,
    _GetNextChar = _GetNextChar
}

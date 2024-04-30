
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

describe("smartclose", function ()
    it("can be required", function ()
        require("smartclose")
    end)

    it("can close (", function ()
        local c = require("smartclose")._GetNextChar("(", 100)
        assert.are.same(c, ")")
    end)
    it("can close [", function ()
        local c = require("smartclose")._GetNextChar("[", 100)
        assert.are.same(c, "]")
    end)
    it("can close {", function ()
        local c = require("smartclose")._GetNextChar("{", 100)
        assert.are.same(c, "}")
    end)
    -- it("can close <", function ()
    --     local c = require("smartclose")._GetNextChar("<", 100)
    --     assert.are.same(c, ">")
    -- end)
    it("can close \"", function ()
        local c = require("smartclose")._GetNextChar("\"", 100)
        assert.are.same(c, "\"")
    end)
    it("can close \'", function ()
        local c = require("smartclose")._GetNextChar("\'", 100)
        assert.are.same(c, "\'")
    end)
    it("can close after multiple open", function ()
        local c = require("smartclose")._GetNextChar("([{<(", 100)
        assert.are.same(c, ")")
    end)
    it("can close after previous close", function ()
        local c = require("smartclose")._GetNextChar("(()", 100)
        assert.are.same(c, ")")
    end)
    it("can close after other char close", function ()
        local c = require("smartclose")._GetNextChar("({}", 100)
        assert.are.same(c, ")")
    end)
    it("can close \"", function ()
        local c = require("smartclose")._GetNextChar("(\"\"\"", 100)
        assert.are.same(c, "\"")
    end)
    it("can close \'", function ()
        local c = require("smartclose")._GetNextChar("(\'\'\'", 100)
        assert.are.same(c, "\'")
    end)
    it("can correctly ignore to close \"", function ()
        local c = require("smartclose")._GetNextChar("(\"\"\"", 100)
        assert.are.same(c, "\"")
    end)
    it("can handle if all is closed \"", function ()
        local c = require("smartclose")._GetNextChar("{[()]}()", 100)
        assert.are.same(c, nil)
    end)
    it("can handle \"(\"", function ()
        local c = require("smartclose")._GetNextChar("\"(\"", 100)
        assert.are.same(c, ")")
    end)
end)

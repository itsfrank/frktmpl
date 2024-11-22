local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local frktmpl = require("./frktmpl")

local m_lune_processor = {}

local function to_lines(str: string): { string }
    local lines = {}
    for line in str:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    return lines
end

function m_lune_processor.process_file(
    e: frktmpl.Engine,
    replacement_table: { [string]: string },
    path: string
): string?
    local lines = string.split(fs.readFile(path), "\n")

    for i, l in lines do
        if l == "" then
            continue
        end
        local line_out, err = frktmpl.apply(e, l, replacement_table)
        if err ~= nil then
            local message = `error: {path}:{i}\n  {table.concat(err, "  \n")}`
            print(`{stdio.color("red")}{message}{stdio.color("reset")}`)
            return nil
        end
        lines[i] = line_out
    end
    return table.concat(lines, "\n")
end

return m_lune_processor

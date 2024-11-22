local process = require("@lune/process")
local serde = require("@lune/serde")
local fs = require("@lune/fs")

local frktmpl = require("@src/frktmpl")
local lune_processor = require("@src/lune_processor")

local function print_usage()
    print("usage: frktmpl source_file replacement_json")
end

if #process.args < 2 then
    print_usage()
    process.exit(1)
end

local process_file = process.args[1]
local replacement_file = process.args[2]

local replacement_table = serde.decode("json", fs.readFile(replacement_file))

local engine = frktmpl.new_engine()
local process_out = lune_processor.process_file(engine, replacement_table, process_file)

if process_out == nil then
    process.exit(1)
end

print(process_out)

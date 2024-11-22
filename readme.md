# frktmpl

A templating library for Luau source code.

This is for a very niche usecase where you want to replace variable in-source but still benefit from Luau typechecking.

## syntax

By default two templating patterns are recognized:

- `__t_<key>` will replace text matching `key` verbatim
- `__tq_<key>` will replace text matching `key` wrapped in quotes

A key can contain any of: lower or upper case letters, numbers, underscores

E.g. Given the following replacement table:

```lua
{
    hello = "Hello",
    world = "World",
}
```

The template:

```lua
local hello = "__t_hello"
local world = __tq_world
print(hello .. " " .. world)
```

becomes:

```lua
local hello = "Hello"
local world = "World"
print(hello .. " " .. world)
```

## use

frktmpl can be used either as a library, or a cli with `lune run ./bin/frktmpl.luau input_template replacement.json`

Using as a library is very simple, create an engine, replacement table, and apply it to a string:

```luau
local frktmpl = require("frktmpl/frktmpl")

local engine = frktmpl.new_engine()
-- here you can change the pattern prefixes, add your own with the `.transformers` table, or set options (see ./src/frktmpl.luau)

local replacements = {
    hello = "Hello",
    world = "World",
}

local str_out, errors = engine:apply(str_in, replacements)
```

If you will be using frktmpl to process files with lune, `./src/lune_processor` provides a convenient wrapper:

```luau
local frktmpl = require("frktmpl/frktmpl")
local lune_processor = require("frktmpl/lune_processor")

local file_to_process = "path/to/my_file.luau"

local engine = frktmpl.new_engine()
local replacements = { ... }

local process_out = lune_processor.process_file(engine, replacements, file_to_process)
if process_out == nil then
    process.exit(1) -- if output is nil, errors have already been printed to the console
end

-- do someting with process_out
```

local m_frktmpl = {}

local DEFAULT_PREFIX = "__t_"
local DEFAULT_QUOTED_PREFIX = "__tq_" -- will wrap content with quotes

export type Transformer = (string) -> string
export type TransformerMap = { [string]: Transformer }
export type EngineOptions = {
    ignore_unknown: boolean, -- if this is false, when we find a template identifier that has no replacement value, we error, if true, we leave it as-is
    ignore_local_definitions: boolean, -- if the template is predeeded by 'local ' it will be skipped, lets you write syntactically valid luau
}

export type Engine = {
    prefix: string,
    quoted_prefix: string,
    transformers: TransformerMap,
    options: EngineOptions,

    apply: (e: Engine, str_in: string, replacement_table: { [string]: string }) -> (string, { string }?),
}

function m_frktmpl.new_engine(): Engine
    local engine: Engine = {
        prefix = DEFAULT_PREFIX,
        quoted_prefix = DEFAULT_QUOTED_PREFIX,
        transformers = {},
        options = {
            ignore_unknown = false,
            ignore_local_definitions = true,
        },

        apply = m_frktmpl.apply
    }

    return engine
end

local function make_local_transfomers(e: Engine): TransformerMap
    local ts = table.clone(e.transformers)
    ts[e.prefix] = function(s: string)
        return s
    end
    ts[e.quoted_prefix] = function(s: string)
        return `"{s}"`
    end

    return ts
end

function process_str(
    pattern: string,
    transform: Transformer,
    replacement_table: { [string]: string },
    str_in: string,
    options: EngineOptions
): (string, { string }?)
    local errors = {}
    local str_out = ""
    local last_end = 1

    local search_pattern = `{pattern}[%w_]+`
    local match_start, match_end = 1 :: number?, 1 :: number?
    while true do
        match_start, match_end = string.find(str_in, search_pattern, match_end)
        if match_start == nil or match_end == nil then
            break
        end

        if last_end < match_start then
            str_out ..= string.sub(str_in, last_end, match_start - 1)
        end
        last_end = match_end + 1

        local match = string.sub(str_in, match_start, match_end)
        if options.ignore_local_definitions then
            if string.sub(str_in, match_start - 6, match_start - 1) == "local " then
                str_out ..= match
                continue
            end
        end

        local key = string.sub(match, #pattern + 1)
        if replacement_table[key] == nil then
            if not options.ignore_unknown then
                table.insert(errors, `no replacement found for key '{key}' in pattern '{match}'`)
            end
            continue
        end

        str_out ..= transform(replacement_table[key])
    end

    str_out ..= string.sub(str_in, last_end)

    return str_out, if #errors == 0 then nil else errors
end

local function safe_insert<T>(dst: { T }?, src: { T }?): { T }?
    if dst ~= nil and src ~= nil then
        table.move(src, 1, #src, #dst + 1, dst)
        return dst
    elseif dst ~= nil then
        return dst
    elseif src ~= nil then
        return src
    end
    return nil
end

function m_frktmpl.apply(e: Engine, str_in: string, replacement_table: { [string]: string }): (string, { string }?)
    local errors = nil
    local str_out = str_in
    local ts = make_local_transfomers(e)
    for p, t in ts do
        local err
        str_out, err = process_str(p, t, replacement_table, str_out, e.options)
        errors = safe_insert(errors, err)
    end

    return str_out, errors
end

return m_frktmpl

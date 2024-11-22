local frktest = require("@pkg/frktest")
local test = frktest.test
local check = frktest.assert.check

local frktmpl = require("@src/frktmpl")

return function()
    test.suite("frktmpl", function()
        local test_data: {
            {
                name: string,
                str_in: string,
                str_exp: string,
                rep: { [string]: string },
                options: frktmpl.EngineOptions?,
            }
        } =
            {
                {
                    name = "identity",
                    str_in = "Hello World",
                    str_exp = "Hello World",
                    rep = {},
                },
                {
                    name = "simple replace",
                    str_in = "Hello __t_world",
                    str_exp = "Hello World",
                    rep = {
                        world = "World",
                    },
                },
                {
                    name = "quoted replace",
                    str_in = "Hello __tq_world",
                    str_exp = 'Hello "World"',
                    rep = {
                        world = "World",
                    },
                },
                {
                    name = "two replacements",
                    str_in = 'print(__tq_hello .. " " .. "__t_world")',
                    str_exp = 'print("Hello" .. " " .. "World")',
                    rep = {
                        hello = "Hello",
                        world = "World",
                    },
                },
                {
                    name = "ignore local",
                    str_in = "local __tq_hello = __tq_hello",
                    str_exp = 'local __tq_hello = "Hello"',
                    rep = { hello = "Hello" },
                },
                {
                    name = "more complex names",
                    str_in = "hello __t_your_name, __t_greeting2",
                    str_exp = "hello frank, i'm a test",
                    rep = { your_name = "frank", greeting2 = "i'm a test" },
                },
            }

        for _, tt in test_data do
            test.case("case: " .. tt.name, function()
                local e = frktmpl.new_engine()
                if tt.options then
                    e.options = tt.options
                end

                local got, err = e:apply(tt.str_in, tt.rep)
                check.equal(got, tt.str_exp)
                if err ~= nil then
                    check.array.equal(err, {})
                end
            end)
        end
    end)
end

function load_tests()
    -- tests execute in the order they are loaded
    require("./tests")()
end

function run_tests()
    local frktest = require("@pkg/frktest")

    frktest._reporters.lune_console_reporter.init()
    local success = frktest.run()
    if not success then
        require("@lune/process").exit(1)
    end
end

load_tests()
run_tests()

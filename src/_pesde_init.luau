local frktmpl = require("./frktmpl")
local lune_processor = require("./lune_processor")

type T = typeof(frktmpl) & { _lune_processor: typeof(lune_processor) }

(frktmpl :: any)._lune_processor = lune_processor

return frktmpl :: T

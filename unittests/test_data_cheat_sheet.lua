lu = require('externals/luaunit/luaunit')
require('scripts/utilities_lua')
require('scripts/data/data_troops')
require('scripts/data/data_cheat_sheet')

os.exit( lu.LuaUnit.run() )

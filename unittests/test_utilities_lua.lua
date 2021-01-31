lu = require('externals/luaunit/luaunit')
require('scripts/utilities_lua')

function test_is_table_empty_returns_true_for_empty()
  local t = {}
  lu.assertTrue( is_table_empty(t) )
end

function test_is_table_empty_returns_false_for_non_empty()
  local t = {a=4}
  lu.assertFalse( is_table_empty(t) )
end

function test_is_table_empty_cannot_have_nil_table()
  local t = nil
  local f=function() return is_table_empty(t) end
  if  pcall(f) then
    lu.assertTrue(false) -- error is expected
  else 
    -- error is expected
  end
end


os.exit( lu.LuaUnit.run() )

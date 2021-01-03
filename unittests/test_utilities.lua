lu = require('externals/luaunit/luaunit')
require('scripts/utilities')

function test_vec_dot_product()
  local vec1={x=1,y=2,z=3}
  local vec2={x=4,y=5,z=6}
  local actual = vec_dot_product(vec1, vec2)
  lu.assertEquals(actual, 32)
end

os.exit( lu.LuaUnit.run() )

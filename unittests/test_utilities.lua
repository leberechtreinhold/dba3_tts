lu = require('externals/luaunit/luaunit')
require('scripts/utilities')

function test_vec_dot_product()
  local vec1={x=1,y=2,z=3}
  local vec2={x=4,y=5,z=6}
  local actual = vec_dot_product(vec1, vec2)
  lu.assertEquals(actual, 32)
end

function test_vec_dot_product_2d()
  local vec1={x=1,z=3}
  local vec2={x=4,z=6}
  local actual = vec_dot_product(vec1, vec2)
  lu.assertEquals(actual, 22)
end

-- Returns the minimum and maximum value of each ordinate.
-- n-dimensional bounding box
function test_bounding_box()
  local p1 = {x=12,z=23}
  local p2 = {x=9,z=48}
  local p3 = {x=48,z=93}
  local p4 = {x=56,z=63}
  local shape = {p1, p2, p3, p4}
  local actual = bounding_box(shape)
 
  local expected={min={x=9,z=23}, max={x=56,z=93}}
  lu.assertEquals(actual, expected)
end

function test_bounding_box_with_named_corners()
  local p1 = {x=12,z=23}
  local p2 = {x=9,z=48}
  local p3 = {x=48,z=93}
  local p4 = {x=56,z=63}
  local shape = {tl=p1, tr=p2, bl=p3, br=p4}
  local actual = bounding_box(shape)
 
  local expected={min={x=9,z=23}, max={x=56,z=93}}
  lu.assertEquals(actual, expected)
end

os.exit( lu.LuaUnit.run() )

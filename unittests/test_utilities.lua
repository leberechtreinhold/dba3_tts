lu = require('externals/luaunit/luaunit')
require('scripts/utilities')


function test_vec_add_3d()
  local vec1={x=1,y=2,z=3}
  local vec2={x=4,y=5,z=6}
  local actual = vec_add(vec1, vec2)
  local expected={x=5,y=7,z=9}
  lu.assertEquals(actual, expected)
end

function test_vec_add_2d()
  local vec1={x=1,z=3}
  local vec2={x=4,z=6}
  local actual = vec_add(vec1, vec2)
  local expected={x=5,z=9}
  lu.assertEquals(actual, expected)
end

function test_vec_add_arbitrary_number_of_vectors()
  local vec1={x=1,z=3}
  local vec2={x=4,z=6}
  local vec3={x=7,z=8}
  local actual = vec_add_n({vec1, vec2, vec3})
  local expected={x=12,z=17}
  lu.assertEquals(actual, expected)
end

function test_vec_div_escalar_3d()
  local v = {x=2,y=16,z=64}
  local actual = vec_div_escalar(v, 2)
  local expected = {x=1,y=8,z=32}
  lu.assertEquals(actual, expected)
end

function test_vec_div_escalar_2d()
  local v = {x=2,z=64}
  local actual = vec_div_escalar(v, 2)
  local expected = {x=1,z=32}
  lu.assertEquals(actual, expected)
end

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

function test_point_is_in_bounding_box()
  local box={min={x=9,z=23}, max={x=56,z=93}}
  local point={x=33,z=78}
  lu.assertTrue(is_point_in_bounding_box(point,box))
end

function test_point_is_to_right_of_bounding_box()
  local box={min={x=9,z=23}, max={x=56,z=93}}
  local point={x=3,z=78}
  lu.assertFalse(is_point_in_bounding_box(point,box))
end

function test_point_is_above_bounding_box()
  local box={min={x=9,z=23}, max={x=56,z=93}}
  local point={x=33,z=178}
  lu.assertFalse(is_point_in_bounding_box(point,box))
end

function test_is_in_range_too_small()
  lu.assertFalse( is_in_range(12, 9, 23))
end

function test_is_in_range_too_large()
  lu.assertFalse( is_in_range(12, 99, 23))
end

function test_is_in_range()
  lu.assertTrue( is_in_range(12, 19, 23))
end

function test_is_bounding_boxes_intersecting_return_true()
  local box1={min={x=9,z=23}, max={x=56,z=93}}
  local box2={min={x=19,z=27}, max={x=66,z=103}}
  lu.assertTrue( is_bounding_boxes_intersecting(box1, box2))
end

function test_is_bounding_boxes_intersecting_return_false()
  local box1={min={x=9,z=23}, max={x=56,z=93}}
  local box2={min={x=87,z=1}, max={x=107,z=103}}
  lu.assertFalse( is_bounding_boxes_intersecting(box1, box2))
end

function test_mid_point()
  local shape = { {x=1, y=0, z=2}, {x=3,y=0,z=4}, {x=51,y=0,z=52}, {x=54,y=0,z=54}}  
  local actual = mid_point(shape)
  local expected = {x=27.25, y=0, z=28}
  lu.assertEquals(actual, expected)
end

function test_mid_point_2d()
  local shape = { {x=1,z=2}, {x=3,z=4}, {x=51,z=52}, {x=54,z=54}}  
  local actual = mid_point(shape)
  local expected = {x=27.25, z=28}
  lu.assertEquals(actual, expected)
end

function test_is_point_in_2d_triangle_returns_true()
  local shape = { {x=1,z=2}, {x=13,z=1}, {x=6,z=52}}  
  local mid = mid_point(shape)
  local actual = is_point_in_2d_triangle(mid, shape[1], shape[2], shape[3])
  lu.assertTrue(actual)
end

function test_is_point_in_2d_triangle_returns_false()
  local shape = { {x=1,z=2}, {x=13,z=1}, {x=6,z=52}}  
  local p = {x=0,z=0}
  local actual = is_point_in_2d_triangle(p, shape[1], shape[2], shape[3])
  lu.assertFalse(actual)
end

function test_is_point_in_2d_shape_returns_false()
  local shape = { {x=1,z=2}, {x=51,z=52}, {x=101,z=102}, {x=151,z=152}}  
  local p = {x=0,z=0}
  local actual = is_point_in_2d_shape(p, shape)
  lu.assertFalse(actual)
end

function test_is_point_in_2d_shape_returns_true_in_first_triangle()
  local shape = { {x=1,z=2}, {x=3,z=52}, {x=101,z=102}, {x=151,z=152}}  
  local shape_mid = mid_point(shape)
  local p = mid_point{ shape[1], shape[2], shape_mid}
  local actual = is_point_in_2d_shape(p, shape)
  lu.assertTrue(actual)
end

function test_is_point_in_2d_shape_returns_true_for_second_to_last_triangle()
  local shape = { {x=1,z=2}, {x=3,z=52}, {x=101,z=102}, {x=151,z=152}}  
  local shape_mid = mid_point(shape)
  local p = mid_point{ shape[3], shape[4], shape_mid}
  local actual = is_point_in_2d_shape(p, shape)
  lu.assertTrue(actual)
end 

function test_is_point_in_2d_shape_returns_true_for_last_triangle()
  local shape = { {x=1,z=2}, {x=3,z=52}, {x=101,z=102}, {x=151,z=152}}  
  local shape_mid = mid_point(shape)
  local p = mid_point{ shape[4], shape[1], shape_mid}
  local actual = is_point_in_2d_shape(p, shape)
  lu.assertTrue(actual)
end 

os.exit( lu.LuaUnit.run() )

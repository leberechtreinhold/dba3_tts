
package.path="?.lua;?.ttslua"

lu = require('externals/luaunit/luaunit')
require('scripts/data/data_settings')
require('scripts/utilities')
require('mock_base')

function test_shallow_copy_on_number_returns_itself()
  local expected = 3.14
  local actual = shallow_copy(expected)
  lu.assertAlmostEquals(actual, expected, 1e-6)
end

function test_shallow_copy_on_table_returns_table_with_same_key_values()
  local expected = { a=1, b=2, c=3}
  local actual = shallow_copy(expected)
  lu.assertEquals(actual, expected)
end


function test_shallow_copy_on_table_returns_new_table()
  local expected = { a=1, b=2, c=3}
  local actual = shallow_copy(expected)
  expected['a'] = 4
  lu.assertEquals(actual['a'], 1)
end

function test_shallow_copy_does_not_copy_nested_tables()
  local expected = { a=1, b=2, c=3, d={e=4}}
  local actual = shallow_copy(expected)
  expected['d']['e'] = 6
  lu.assertEquals(actual['d']['e'], 6)
end

function test_deep_copy_on_number_returns_itself()
  local expected = 3.14
  local actual = deep_copy(expected)
  lu.assertAlmostEquals(actual, expected, 1e-6)
end

function test_deep_copy_on_table_returns_table_with_same_key_values()
  local expected = { a=1, b=2, c=3}
  local actual = deep_copy(expected)
  lu.assertEquals(actual, expected)
end


function test_deep_copy_on_table_returns_new_table()
  local expected = { a=1, b=2, c=3}
  local actual = deep_copy(expected)
  expected['a'] = 4
  lu.assertEquals(actual['a'], 1)
end

function test_deep_copy_does_copies_nested_tables()
  local expected = { a=1, b=2, c=3, d={e=4}}
  local actual = deep_copy(expected)
  expected['d']['e'] = 6
  lu.assertEquals(actual['d']['e'], 4)
end

function test_copy_base_returns_different_function_capture_getrotation()
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  moving_base.setRotation({ 0,  90, 0})
  local expected_moving = copy_base(moving_base)   
  jiggle(moving_base)
  local actual_rotation = moving_base.getRotation()
  local expected_rotation = expected_moving.getRotation()
  lu.assertTrue(actual_rotation.y ~= expected_rotation.y)
end

function test_copy_base_returns_different_function_capture_getposition()
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  moving_base.setRotation({ 0,  90, 0})
  local expected_moving = copy_base(moving_base)   
  jiggle(moving_base)
  local actual_position = moving_base.getPosition()
  local expected_position = expected_moving.getPosition()
  lu.assertTrue(actual_position.z ~= expected_position.z)
end


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

function test_normalize_radians_makes_number_non_negative()
  local expected = math.pi / 4
  local actual = normalize_radians ( expected - (4 * math.pi))
  lu.assertAlmostEquals(actual, expected, 0.001)
end

function test_normalize_radians_makes_number_less_than_2_pi()
  local expected = math.pi / 4
  local actual = normalize_radians ( expected + (4 * math.pi))
  lu.assertAlmostEquals(actual, expected, 0.001)
end

function test_normalize_radians_leaves_zero_alone()
  local expected = 0
  local actual = normalize_radians ( expected )
  lu.assertAlmostEquals(actual, expected, 0.001)
end

function test_normalize_radians_reduces_2_pi_to_zero()
  local expected = 0
  local actual = normalize_radians ( expected + (2 * math.pi))
  lu.assertAlmostEquals(actual, expected, 0.001)
end

function test_normalize_degress_makes_number_non_negative()
  local expected = 45
  local actual = normalize_degrees ( expected - 720)
  lu.assertAlmostEquals(actual, expected, 0.001)
end

function test_normalize_degrees_makes_number_less_than_360()
  local expected =45
  local actual = normalize_degrees ( expected + 720)
  lu.assertAlmostEquals(actual, expected, 0.001)
end

function test_normalize_degrees_leaves_zero_alone()
  local expected = 0
  local actual = normalize_degrees ( expected )
  lu.assertAlmostEquals(actual, expected, 0.001)
end

function test_normalize_degrees_reduces_360_to_zero()
  local expected = 0
  local actual = normalize_degrees ( expected + 360)
  lu.assertAlmostEquals(actual, expected, 0.001)
end


function test_is_rad_angle_diff_true_if_same()
  local actual = is_rad_angle_diff(math.pi, math.pi, 0)
  lu.assertTrue(actual)
end

function test_is_rad_angle_diff_true_if_b_slightly_smaller()
  local actual = is_rad_angle_diff(math.pi, math.pi - g_max_angle_pushback_rad/2, 0)
  lu.assertTrue(actual)
end

function test_is_rad_angle_diff_false_if_b_smaller()
  local actual = is_rad_angle_diff(math.pi, math.pi - (g_max_angle_pushback_rad*1.1), 0)
  lu.assertFalse(actual)
end

function test_is_rad_angle_diff_true_if_b_slightly_larger()
  local actual = is_rad_angle_diff(math.pi, math.pi + g_max_angle_pushback_rad*0.51, 0)
  lu.assertTrue(actual)
end

function test_is_rad_angle_diff_false_if_b_larger()
  local actual = is_rad_angle_diff(math.pi, math.pi + g_max_angle_pushback_rad*1.1, 0)
  lu.assertFalse(actual)
end

function test_is_rad_angle_diff_true_if_close_a_negative()
  local actual = is_rad_angle_diff(-g_max_angle_pushback_rad/4, g_max_angle_pushback_rad/4, 0)
  lu.assertTrue(actual)
end

function test_is_rad_angle_diff_true_if_close_b_negative()
  local actual = is_rad_angle_diff(g_max_angle_pushback_rad/4, -g_max_angle_pushback_rad/4, 0)
  lu.assertTrue(actual)
end

function test_is_rad_angle_diff_false_if_a_negative()
  local actual = is_rad_angle_diff(-g_max_angle_pushback_rad*0.51, g_max_angle_pushback_rad*0.51, 0)
  lu.assertFalse(actual)
end

function test_is_rad_angle_diff_true_if_close_a_large()
  local a = (2 * math.pi) - (g_max_angle_pushback_rad/4)
  local b = (g_max_angle_pushback_rad/4)
  local actual = is_rad_angle_diff(a,b, 0)
  lu.assertTrue(actual)
end

function test_is_rad_angle_diff_true_if_close_a_very_large()
  local a = (10 * math.pi) - (g_max_angle_pushback_rad/4)
  local b = (g_max_angle_pushback_rad/4)
  local actual = is_rad_angle_diff(a,b, 0)
  lu.assertTrue(actual)
end

function test_is_rad_angle_diff_true_if_close_b_very_large()
  local a = (8 * math.pi)
  local b = a + (g_max_angle_pushback_rad/4)
  local actual = is_rad_angle_diff(a,b, 0)
  lu.assertTrue(actual)
end

function test_is_rad_angle_diff_true_if_close_a_very_large_negative()
  local a = -(10 * math.pi) - (g_max_angle_pushback_rad/4)
  local b = (g_max_angle_pushback_rad/4)
  local actual = is_rad_angle_diff(a,b, 0)
  lu.assertTrue(actual)
end

function test_is_rad_angle_diff_true_for_expected_angle_small_negative()
  local a = 0
  local b = math.pi/2
  local actual = is_rad_angle_diff(a,b, -0.5 * math.pi)
  lu.assertTrue(actual)
end

function test_is_rad_angle_diff_false_for_expected_angle_small_negative()
  local a = math.pi/2
  local b = 0
  local actual = is_rad_angle_diff(a,b, -0.5 * math.pi)
  lu.assertFalse(actual)
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
  local shape = { {x=1,z=2}, {x=51,z=52}, {x=101,z=102}, {x=102,z=103}, {x=151,z=152}}
  local p = {x=0,z=0}
  local actual = is_point_in_2d_shape(p, shape)
  lu.assertFalse(actual)
end

function test_is_point_in_2d_shape_returns_true_if_shape_is_triangle()
  local shape = { {x=1,z=2}, {x=13,z=1}, {x=6,z=52}}
  local p = mid_point(shape)
  local actual = is_point_in_2d_shape(p, shape)
  lu.assertTrue(actual)
end

function test_is_point_in_2d_shape_returns_true_if_shape_is_rectangle_point_above_mid()
  local shape = { {x=1,z=2}, {x=13,z=1}, {x=6,z=52}}
  local p = mid_point(shape)
  p['z'] =  p['z'] + 1
  local actual = is_point_in_2d_shape(p, shape)
  lu.assertTrue(actual)
end

function test_is_point_in_2d_shape_returns_true_if_shape_is_rectangle_point_below_mid()
  local shape = { {x=1,z=2}, {x=13,z=1}, {x=6,z=52}}
  local p = mid_point(shape)
  p['z'] =  p['z'] + 1
  local actual = is_point_in_2d_shape(p, shape)
  lu.assertTrue(actual)
end

function test_is_point_in_2d_shape_returns_true_in_first_triangle()
  local shape = { {x=1,z=2}, {x=3,z=52}, {x=101,z=102},{x=102,z=103}, {x=151,z=152}}
  local shape_mid = mid_point(shape)
  local p = mid_point{ shape[1], shape[2], shape_mid}
  local actual = is_point_in_2d_shape(p, shape)
  lu.assertTrue(actual)
end

function test_is_point_in_2d_shape_returns_true_for_second_to_last_triangle()
  local shape = { {x=1,z=2}, {x=3,z=52}, {x=101,z=102},{x=102,z=103}, {x=151,z=152}}
  local shape_mid = mid_point(shape)
  local p = mid_point{ shape[4], shape[5], shape_mid}
  local actual = is_point_in_2d_shape(p, shape)
  lu.assertTrue(actual)
end

function test_is_point_in_2d_shape_returns_true_for_last_triangle()
  local shape = { {x=1,z=2}, {x=3,z=52}, {x=101,z=102},{x=102,z=103}, {x=151,z=152}}
  local shape_mid = mid_point(shape)
  local p = mid_point{ shape[5], shape[1], shape_mid}
  local actual = is_point_in_2d_shape(p, shape)
  lu.assertTrue(actual)
end

function test_is_2d_shapes_intersecting_true()
  local shape1 = { {x=1,z=2}, {x=1,z=12}, {x=21,z=12},{x=21,z=12}}
  local shape2 = { {x=6,z=7}, {x=6,z=17}, {x=26,z=17},{x=26,z=7}}
  local actual = is_2d_shapes_intersecting(shape1, shape2)
  lu.assertTrue(actual)
end

function test_is_2d_shapes_intersecting_false()
  local shape1 = { {x=1,z=2}, {x=1,z=12}, {x=21,z=12},{x=21,z=12}}
  local shape2 = { {x=31,z=2}, {x=31,z=12}, {x=51,z=12},{x=51,z=7}}
  local actual = is_2d_shapes_intersecting(shape1, shape2)
  lu.assertFalse(actual)
end

os.exit( lu.LuaUnit.run() )

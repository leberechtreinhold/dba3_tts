lu = require('externals/luaunit/luaunit')
require('scripts/data/data_settings')
require('scripts/data/data_tables')
require('scripts/data/data_terrain')
require('scripts/data/data_troops')
--require('scripts/data/data_troops_greek_successors')
--require('scripts/data/data_armies_book_I')
--require('scripts/data/data_armies_book_II')
--require('scripts/data/data_armies_book_III')
--require('scripts/data/data_armies_book_IV')
require('scripts/base_cache')
require('scripts/log')
require('scripts/utilities_lua')
require('scripts/utilities')
require('scripts/logic_terrain')
require('scripts/logic_gizmos')
require('scripts/logic_spawn_army')
require('scripts/logic_dead')
require('scripts/logic_dice')
require('scripts/logic_history_stack')
require('scripts/logic')
require('scripts/uievents')

log = function(...)
  -- stub out for testing
end

print_info = function(...)
  -- stub out for testing
end

-- Create a fake base that can be used for
-- testing
function build_base(base_name, tile)
  if tile == nil then
    tile="tile_plain_4Bw_40x20"
  end

  local base = {
    name=base_name,
    position={
      x=1.0057,
      y=1.2244,
      z=2.1356
    },
    rotation={
      x=0,
      y=0,
      z=0
    },
  }

  base['getName']=function()
    return base.name
  end

  base['getPosition']=function()
    return base.position
  end

  base['setPosition']=function(new_value)
    base.position = new_value
  end

  base['getRotation']=function()
    return base.rotation
  end

  base['setRotation']=function(new_value)
    base.rotation = new_value
  end

  g_bases[ base_name] = {
    tile=tile,
    is_red_player=true
  }

  return base
end

function test_turn_around_base()
  local moving_base = build_base("base 4Bw # 16")
  local before = calculate_transform(moving_base)
  turn_around_base(moving_base)
  local after = calculate_transform(moving_base)
  
  local expected_corner = before['corners']['topleft']
  local actual_corner = after['corners']['botright']
  lu.assertAlmostEquals(actual_corner['x'], expected_corner['x'], 0.01)
  lu.assertAlmostEquals(actual_corner['z'], expected_corner['z'], 0.01)
end

function test_rotate_CCW_90()
  lu.assertNotNil(tile_plain_WWg_40x40)
  local moving_base = build_base("base WWg # 19", 'tile_plain_WWg_40x40')
  local before = calculate_transform(moving_base)
  local rotation = moving_base.getRotation()
  rotation['y'] = rotation['y'] - 90
  local after = calculate_transform(moving_base)
  
  local expected_corner = before['corners']['topleft']
  local actual_corner = after['corners']['topright']
  lu.assertAlmostEquals(actual_corner['x'], expected_corner['x'], 0.01)
  lu.assertAlmostEquals(actual_corner['z'], expected_corner['z'], 0.01)
end

function test_distance_points_flat_sq()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediatly behind the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_depth = get_size(resting_base.getName())['z']
  local distance_moved = base_depth
  moving_base.position['z'] = resting_base.position['z'] - distance_moved
  transform_resting = calculate_transform(resting_base)
  transform_moving = calculate_transform(moving_base)
  local corners_resting = transform_resting['corners']
  local corners_moving = transform_moving['corners']

  lu.assertAlmostEquals(distance_points_flat_sq(
    corners_moving['topright'],corners_resting['botright']),
    0, 1e-4)
  lu.assertAlmostEquals(distance_points_flat_sq(
    corners_moving['topright'],corners_resting['topright']),
    distance_moved^2, 1e-4)
  end

function test_distance_behind()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately behind the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_depth = get_size(resting_base.getName())['z']
  moving_base.position['z'] = resting_base.position['z'] - base_depth
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = distance_behind(transform_moving, transform_resting)
  -- max distance between the front and back corners
  lu.assertAlmostEquals(actual, 0, 1e-4)
end

function test_is_behind()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately behind the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_depth = get_size(resting_base.getName())['z']
  moving_base.position['z'] = resting_base.position['z'] - base_depth
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = is_behind(transform_moving, transform_resting)
  lu.assertTrue(actual)
end

function test_distance_infront()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately behind the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_depth = get_size(resting_base.getName())['z']
  moving_base.position['z'] = resting_base.position['z'] + base_depth
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- front and back bases edges are touching
  local actual = distance_infront(transform_moving, transform_resting)
  -- max distance between the front and back corners
  lu.assertAlmostEquals(actual, 0, 1e-4)
end

function test_is_infront()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately behind the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_depth = get_size(resting_base.getName())['z']
  moving_base.position['z'] = resting_base.position['z'] + base_depth
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- front and back bases edges are touching

  local actual = is_infront(transform_moving, transform_resting)
  lu.assertTrue(actual)
end


function test_distance_behind_returns_furthest_distance()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be behind the resting base, but skewed
  -- with one corner within the threshold and one corner more than the
  -- threshold
  moving_base.position = shallow_copy(resting_base.position)
  moving_base['rotation']['y']= g_max_angle_pushback_rad

  local base_depth = get_size(resting_base.getName())['z']
  local threshold = (g_max_corner_distance_snap^0.5)
  moving_base.position['z'] = resting_base.position['z'] - (base_depth + threshold)
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = distance_behind(transform_moving, transform_resting)
  lu.assertFalse(actual > threshold)
end

function test_distance_left_side()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately beside the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_width = get_size(resting_base.getName())['x']
  moving_base.position['x'] = resting_base.position['x'] - base_width
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- left and right bases edges are touching
  local actual = distance_left_side(transform_moving, transform_resting)
  lu.assertAlmostEquals(actual, 0, 1e-4)
end

function test_is_left_side()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately beside the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_width = get_size(resting_base.getName())['x']
  moving_base.position['x'] = resting_base.position['x'] - base_width
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- left and right bases edges are touching
  local actual = is_left_side(transform_moving, transform_resting)
  lu.assertTrue(actual)
end

function test_distance_right_side()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately beside the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_width = get_size(resting_base.getName())['x']
  moving_base.position['x'] = resting_base.position['x'] + base_width
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- right and left bases edges are the touching
  local actual = distance_right_side(transform_moving, transform_resting)
  lu.assertAlmostEquals(actual, 0, 1e-4)
end

function test_is_right_side()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately beside the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_width = get_size(resting_base.getName())['x']
  moving_base.position['x'] = resting_base.position['x'] + base_width
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- right and left bases edges are the touching
  local actual = is_right_side(transform_moving, transform_resting)
  lu.assertTrue(actual)
end

function test_is_right_side()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately beside the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_width = get_size(resting_base.getName())['x']
  moving_base.position['x'] = resting_base.position['x'] + base_width
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- right and left bases edges are the touching
  local actual = is_right_side(transform_moving, transform_resting)
  lu.assertTrue(actual)
end


function test_distance_wwg_aligned_right_back_returns_huge_on_bad_angle()
  -- if the WWg is not facing the right way for the rule to be used
  -- then math.huge is returned.
  local resting_base = build_base("base WWg # 19", 'tile_plain_WWg_40x80')
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x80')
  local base_height = get_depth_base('tile_plain_WWg_40x80')
  moving_base.position['z'] = moving_base.position['z'] - base_height
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = distance_wwg_aligned_right_back(transform_moving, transform_resting)
  lu.assertEquals(actual, math.huge)
end

function test_distance_wwg_aligned_right_back_returns_distance()
  local resting_base = build_base("base Bw # 19")
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  moving_base.rotation['y'] = moving_base.rotation['y'] - 90
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.botleft.x - transform_moving.corners.topright.x
  local delta_z = transform_resting.corners.botleft.z - transform_moving.corners.topright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  transform_moving = calculate_transform(moving_base)
    
  local actual = distance_wwg_aligned_right_back(transform_moving, transform_resting)
  lu.assertAlmostEquals(actual, 0.0, 0.01)
end


function test_distance_wwg_aligned_right_front_returns_huge_on_bad_angle()
  -- if the WWg is not facing the right way for the rule to be used
  -- then math.huge is returned.
  local resting_base = build_base("base WWg # 19", 'tile_plain_WWg_40x80')
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x80')
  local base_height = get_depth_base('tile_plain_WWg_40x80')
  moving_base.position['z'] = moving_base.position['z'] - base_height
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = distance_wwg_aligned_right_front(transform_moving, transform_resting)
  lu.assertEquals(actual, math.huge)
end

function test_distance_wwg_aligned_right_front_returns_distance()
  local resting_base = build_base("base Bw # 19")
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  moving_base.rotation['y'] = moving_base.rotation['y'] - 90
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topright.x - transform_moving.corners.topright.x
  local delta_z = transform_resting.corners.topright.z - transform_moving.corners.topright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  transform_moving = calculate_transform(moving_base)
    
  local actual = distance_wwg_aligned_right_front(transform_moving, transform_resting)
  lu.assertAlmostEquals(actual, 0.0, 0.01)
end


function test_distance_wwg_aligned_left_back_returns_huge_on_bad_angle()
  -- if the WWg is not facing the right way for the rule to be used
  -- then math.huge is returned.
  local resting_base = build_base("base WWg # 19", 'tile_plain_WWg_40x80')
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x80')
  local base_height = get_depth_base('tile_plain_WWg_40x80')
  moving_base.position['z'] = moving_base.position['z'] - base_height
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = distance_wwg_aligned_left_back(transform_moving, transform_resting)
  lu.assertEquals(actual, math.huge)
end


function test_distance_wwg_aligned_left_back_returns_distance()
  local resting_base = build_base("base Bw # 19")
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  moving_base.rotation['y'] = moving_base.rotation['y'] + 90
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.botright.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.botright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  transform_moving = calculate_transform(moving_base)
    
  local actual = distance_wwg_aligned_left_back(transform_moving, transform_resting)
  lu.assertAlmostEquals(actual, 0.0, 0.01)
end



function test_transform_to_shape()
  local base = build_base("base 4Bw # 16")
  local transform = calculate_transform(base)
  local corners = transform['corners']
  local actual = transform_to_shape(transform)
  lu.assertEquals(actual[1], corners['topleft'])
  lu.assertEquals(actual[2], corners['topright'])
  lu.assertEquals(actual[3], corners['botright'])
  lu.assertEquals(actual[4], corners['botleft'])
end

os.exit( lu.LuaUnit.run() )

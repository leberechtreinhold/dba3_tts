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

lu.assertPointEquals = function(a,b)
  lu.assertEquals(a['x'], b['x'])
  lu.assertEquals(a['y'], b['y'])
  lu.assertEquals(a['z'], b['z'])
end

lu.assertPointAlmostEquals = function(a,b)
  lu.assertAlmostEquals(a['x'], b['x'], 0.01)
  lu.assertAlmostEquals(a['y'], b['y'], 0.01)
  lu.assertAlmostEquals(a['z'], b['z'], 0.01)
end

lu.assertBaseEquals = function(a,b)
  lu.assertPointEquals(a.getRotation(), b.getRotation())
  lu.assertPointEquals(a.getPosition(), b.getPosition())
end

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
    return deep_copy(base.rotation)
  end

  base['setRotation']=function(new_value)
    if nil == new_value.x then
      base.rotation['x'] = new_value[1]
      base.rotation['y'] = new_value[2]
      base.rotation['z'] = new_value[3]
    else 
      base.rotation = new_value
    end
  end

  g_bases[ base_name] = {
    tile=tile,
    is_red_player=true
  }

  return base
end

-- slightly disturb the base position and rotation so we can
-- check that snapping works.
function jiggle(base)
  local position = base.getPosition()
  position['x'] = position['x'] + 0.15
  position['x'] = position['z'] + 0.2
  base.setPosition(position)
  
  local rotation = base.getRotation()
  rotation['y'] = rotation['y'] + 5
  base.setRotation(rotation)
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

function test_calculate_transform_keeps_rotation_between_zero_and_two_pi_negative_degrees()
  local base = build_base("base WWg # 19", 'tile_plain_WWg_40x40')
  base.setRotation({0, -90, 0})
  local t = calculate_transform(base)
  local actual= t.rotation
  lu.assertTrue(0 <= actual)
  lu.assertTrue(actual < (2*math.pi))
end

function test_calculate_transform_keeps_rotation_between_zero_and_two_pi_large_positive_degrees()
  local base = build_base("base WWg # 19", 'tile_plain_WWg_40x40')
  base.setRotation({0,  90 + 720, 0 })
  local t = calculate_transform(base)
  local actual= t.rotation
  lu.assertTrue(0 <= actual)
  lu.assertTrue(actual < (2*math.pi))
end

function test_rotate_CCW_90()
  lu.assertNotNil(tile_plain_WWg_40x40)
  local moving_base = build_base("base WWg # 19", 'tile_plain_WWg_40x40')
  local before = calculate_transform(moving_base)
  moving_base.setRotation({0, -90, 0})
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

function test_distance_front_to_back()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately behind the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_depth = get_size(resting_base.getName())['z']
  moving_base.position['z'] = resting_base.position['z'] - base_depth
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = distance_front_to_back(transform_moving, transform_resting)
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

function test_distance_back_to_front()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately behind the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_depth = get_size(resting_base.getName())['z']
  moving_base.position['z'] = resting_base.position['z'] + base_depth
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- front and back bases edges are touching
  local actual = distance_back_to_front(transform_moving, transform_resting)
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


function test_distance_front_to_back_returns_furthest_distance()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be behind the resting base, but skewed
  -- with one corner within the threshold and one corner more than the
  -- threshold
  moving_base.position = shallow_copy(resting_base.position)
  moving_base.setRotation({0,  g_max_angle_pushback_rad, 0})

  local base_depth = get_size(resting_base.getName())['z']
  local threshold = (g_max_corner_distance_snap^0.5)
  moving_base.position['z'] = resting_base.position['z'] - (base_depth + threshold)
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = distance_front_to_back(transform_moving, transform_resting)
  lu.assertFalse(actual > threshold)
end

function test_distance_right_to_left_side()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately beside the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_width = get_size(resting_base.getName())['x']
  moving_base.position['x'] = resting_base.position['x'] - base_width
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- left and right bases edges are touching
  local actual = distance_right_to_left_side(transform_moving, transform_resting)
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

function test_distance_left_to_right_side()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be immediately beside the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_width = get_size(resting_base.getName())['x']
  moving_base.position['x'] = resting_base.position['x'] + base_width
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  -- right and left bases edges are the touching
  local actual = distance_left_to_right_side(transform_moving, transform_resting)
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


function test_distance_right_to_back_returns_huge_on_bad_angle()
  -- if the WWg is not facing the right way for the rule to be used
  -- then math.huge is returned.
  local resting_base = build_base("base WWg # 19", 'tile_plain_WWg_40x80')
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x80')
  local base_height = get_depth_base('tile_plain_WWg_40x80')
  moving_base.position['z'] = moving_base.position['z'] - base_height
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = distance_right_to_back(transform_moving, transform_resting)
  lu.assertEquals(actual, math.huge)
end

function test_distance_right_to_back_returns_distance()
  local resting_base = build_base("base Bw # 19")
  
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  moving_base.setRotation({0, -90, 0})
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.botleft.x - transform_moving.corners.topright.x
  local delta_z = transform_resting.corners.botleft.z - transform_moving.corners.topright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  transform_moving = calculate_transform(moving_base)
  -- assert that the bases are located where they are supposed to be.
  local corners = transform_moving.corners
  local tr = corners['topright']
  local tl = corners['topleft']
  local br = corners['botright']
  local bl = corners['botleft']
  -- assert TR relations
  lu.assertAlmostEquals(tr.x, tl.x, 0.01)
  lu.assertTrue(tr.z > tl.z)
  lu.assertAlmostEquals(tr.z, br.z, 0.01)
  -- assert TL relations
  lu.assertAlmostEquals(tl.z, bl.z, 0.01)
  lu.assertTrue(tl.x < bl.x)
  -- assert BR relations
  lu.assertTrue(br.z > bl.z)
  lu.assertAlmostEquals(br.x, bl.x, 0.01)
    
  -- Exercise  
  local actual = distance_right_to_back(transform_moving, transform_resting)

  -- Validate
  lu.assertAlmostEquals(actual, 0.0, 0.01)
end

function test_snap_to_base_wwg_right_to_back()
  -- Setup
  local resting_base = build_base("base Bw # 19")
  local original_base = deep_copy(resting_base)
  
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  moving_base.setRotation({0, -90, 0})
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.botleft.x - transform_moving.corners.topright.x
  local delta_z = transform_resting.corners.botleft.z - transform_moving.corners.topright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  transform_moving = calculate_transform(moving_base)
  local corners = transform_moving.corners
  local tr = shallow_copy(corners['topright'])
  local tl = shallow_copy(corners['topleft'])
  local br = shallow_copy(corners['botright'])
  local bl = shallow_copy(corners['botleft'])
  local rotation = transform_moving['rotation']
  -- assert that the bases are located where they are supposed to be.
  -- assert TR relations
  lu.assertAlmostEquals(tr.x, tl.x, 0.01)
  lu.assertTrue(tr.z > tl.z)
  lu.assertAlmostEquals(tr.z, br.z, 0.01)
  -- assert TL relations
  lu.assertAlmostEquals(tl.z, bl.z, 0.01)
  lu.assertTrue(tl.x < bl.x)
  -- assert BR relations
  lu.assertTrue(br.z > bl.z)
  lu.assertAlmostEquals(br.x, bl.x, 0.01)

  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)
  
  -- assert right back rule applies
  local fixup_distance_sq = distance_right_to_back(transform_moving, transform_resting)
  lu.assertTrue(fixup_distance_sq  < math.huge)

  -- Exericse 
  -- snap to base should have nothing to do
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'wwg_right_to_back')
  
  -- Verify
  local transform_actual = calculate_transform(moving_base)
  local actual_rotation = transform_actual.rotation
  lu.assertAlmostEquals(actual_rotation, rotation, 0.01)
  local corners_actual = transform_actual['corners']
  lu.assertPointAlmostEquals(corners_actual.topleft, tl)  
  lu.assertPointAlmostEquals(corners_actual.topright, tr)  
  lu.assertPointAlmostEquals(corners_actual.botleft, bl)  
  lu.assertPointAlmostEquals(corners_actual.botright, br)  
  lu.assertBaseEquals(resting_base, original_base)
end


function test_distance_right_to_front_returns_huge_on_bad_angle()
  -- if the WWg is not facing the right way for the rule to be used
  -- then math.huge is returned.
  local resting_base = build_base("base WWg # 19", 'tile_plain_WWg_40x80')
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x80')
  local base_height = get_depth_base('tile_plain_WWg_40x80')
  moving_base.position['z'] = moving_base.position['z'] - base_height
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = distance_right_to_front(transform_moving, transform_resting)
  lu.assertEquals(actual, math.huge)
end

function test_distance_right_to_front_returns_distance()
  local resting_base = build_base("base Bw # 19")
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  moving_base.setRotation({0, 90, 0})
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topright.x - transform_moving.corners.topright.x
  local delta_z = transform_resting.corners.topright.z - transform_moving.corners.topright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  transform_moving = calculate_transform(moving_base)
    
  local actual = distance_right_to_front(transform_moving, transform_resting)
  lu.assertAlmostEquals(actual, 0.0, 0.01)
end

function test_snap_to_base_wwg_right_front()
  -- Setup
  local resting_base = build_base("base Bw # 19")
  local original_base = deep_copy(resting_base)
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  moving_base.setRotation({ 0,  90, 0})
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topright.x - transform_moving.corners.topright.x
  local delta_z = transform_resting.corners.topright.z - transform_moving.corners.topright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  transform_moving = calculate_transform(moving_base)
  local corners = transform_moving.corners
  local tr = shallow_copy(corners['topright'])
  local tl = shallow_copy(corners['topleft'])
  local br = shallow_copy(corners['botright'])
  local bl = shallow_copy(corners['botleft'])
  local rotation = transform_moving['rotation']
  -- assert that the bases are located where they are supposed to be.
  -- assert TR relations
  lu.assertAlmostEquals(tr.x, tl.x, 0.01)
  lu.assertTrue(tr.z < tl.z)
  lu.assertAlmostEquals(tr.z, br.z, 0.01)
  -- assert TL relations
  lu.assertAlmostEquals(tl.z, bl.z, 0.01)
  lu.assertTrue(tl.x > bl.x)
  -- assert BR relations
  lu.assertTrue(br.z < bl.z)
  lu.assertAlmostEquals(br.x, bl.x, 0.01)

  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)

  -- assert that the rule applies
  local distance = distance_right_to_front(transform_moving, transform_resting)
  lu.assertTrue(distance < math.huge)
  
  -- Exercise
  -- no movement needed
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'wwg_right_front')
        
  -- Validate
  local transform_actual = calculate_transform(moving_base)
  local actual_rotation = transform_actual.rotation
  lu.assertAlmostEquals(actual_rotation, rotation, 0.01)
  local corners_actual = transform_actual['corners']
  lu.assertPointAlmostEquals(corners_actual.topleft, tl)  
  lu.assertPointAlmostEquals(corners_actual.topright, tr)  
  lu.assertPointAlmostEquals(corners_actual.botleft, bl)  
  lu.assertPointAlmostEquals(corners_actual.botright, br)  
  lu.assertBaseEquals(resting_base, original_base)
end

function test_distance_left_to_back_returns_huge_on_bad_angle()
  -- if the WWg is not facing the right way for the rule to be used
  -- then math.huge is returned.
  local resting_base = build_base("base WWg # 19", 'tile_plain_WWg_40x80')
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x80')
  local base_height = get_depth_base('tile_plain_WWg_40x80')
  moving_base.position['z'] = moving_base.position['z'] - base_height
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = distance_left_to_back(transform_moving, transform_resting)
  lu.assertEquals(actual, math.huge)
end


function test_distance_left_to_back_returns_distance()
  local resting_base = build_base("base Bw # 19")
  resting_base.setRotation({0,270,0})
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  moving_base.setRotation({0, 0, 0})
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.botright.x - transform_moving.corners.topleft.x
  local delta_z = transform_resting.corners.botright.z - transform_moving.corners.topleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  transform_moving = calculate_transform(moving_base)
    
  local actual = distance_left_to_back(transform_moving, transform_resting)
  lu.assertAlmostEquals(actual, 0.0, 0.01)
end


function test_snap_to_base_wwg_left_to_back()
  -- setup
  local resting_base = build_base("base Bw # 19")
  resting_base.setRotation({0, 270, 0})
  local original_base = deep_copy(resting_base)
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  moving_base.setRotation({0, 0, 0})
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.botright.x - transform_moving.corners.topleft.x
  local delta_z = transform_resting.corners.botright.z - transform_moving.corners.topleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  local expected_moving_base = deep_copy(moving_base)
  transform_moving = calculate_transform(moving_base)
  local corners = transform_moving.corners
    
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)
    
  -- assert rule applies
  local distance = distance_left_to_back(transform_moving, transform_resting)
  lu.assertTrue(distance < math.huge)
  
  -- Exercise
  -- no movement needed
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'wwg_left_to_back')
        
  -- Validate
  lu.assertBaseEquals(moving_base, expected_moving_base)
  lu.assertBaseEquals(resting_base, original_base)
end

-- War Wagon is 40x80
function test_snap_to_base_wwg_left_to_back_large()
  -- setup
  local resting_base = build_base("base Bw # 19")
  resting_base.setRotation({0, 270, 0})
  local original_base = deep_copy(resting_base)
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x80')
  moving_base.setRotation({0, 0, 0})
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.botright.x - transform_moving.corners.topleft.x
  local delta_z = transform_resting.corners.botright.z - transform_moving.corners.topleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  local expected_moving_base = deep_copy(moving_base)
  transform_moving = calculate_transform(moving_base)
  local corners = transform_moving.corners
    
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)
    
  -- assert rule applies
  local distance = distance_left_to_back(transform_moving, transform_resting)
  lu.assertTrue(distance < math.huge)
  
  -- Exercise
  -- no movement needed
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'wwg_left_to_back')
        
  -- Validate
  lu.assertBaseEquals(moving_base, expected_moving_base)
  lu.assertBaseEquals(resting_base, original_base)
end

function test_distance_left_to_front_returns_huge_on_bad_angle()
  -- if the WWg is not facing the right way for the rule to be used
  -- then math.huge is returned.
  local resting_base = build_base("base WWg # 19", 'tile_plain_WWg_40x80')
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x80')
  local base_height = get_depth_base('tile_plain_WWg_40x80')
  moving_base.position['z'] = moving_base.position['z'] - base_height
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = distance_left_to_front(transform_moving, transform_resting)
  lu.assertEquals(actual, math.huge)
end

function test_distance_left_to_front_returns_distance()
  local resting_base = build_base("base Bw # 19")
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  moving_base.setRotation({0, 90, 0})
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.topleft.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.topleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  transform_moving = calculate_transform(moving_base)
    
  local actual = distance_left_to_front(transform_moving, transform_resting)
  lu.assertAlmostEquals(actual, 0.0, 0.01)
end


function test_snap_to_base_wwg_left_front()
  -- setup
  local resting_base = build_base("base Bw # 19")
  local original_base = deep_copy(resting_base)
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  moving_base.setRotation({0, 90, 0})
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.topleft.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.topleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  transform_moving = calculate_transform(moving_base)
  local corners = transform_moving.corners
  local tr = shallow_copy(corners['topright'])
  local tl = shallow_copy(corners['topleft'])
  local br = shallow_copy(corners['botright'])
  local bl = shallow_copy(corners['botleft'])
  local rotation = transform_moving['rotation']
    
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)
    
  -- Assert rule applies  
  local distance = distance_left_to_front(transform_moving, transform_resting)
  lu.assertTrue(distance < math.huge)
  -- Assert the orientation
  lu.assertTrue(bl.x < tl.x)
  lu.assertAlmostEquals(bl.z, tl.z, 0.01)
  lu.assertAlmostEquals(bl.x, br.x)
  lu.assertTrue(bl.z > br.z)
  
  -- Exercise
  -- no movement needed
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'wwg_left_front')
        
  -- Validate
  local transform_actual = calculate_transform(moving_base)
  local actual_rotation = transform_actual.rotation
  lu.assertAlmostEquals(actual_rotation, rotation, 0.01)
  local corners_actual = transform_actual['corners']
  lu.assertPointAlmostEquals(corners_actual.topleft, tl)  
  lu.assertPointAlmostEquals(corners_actual.topright, tr)  
  lu.assertPointAlmostEquals(corners_actual.botleft, bl)  
  lu.assertPointAlmostEquals(corners_actual.botright, br)  
  lu.assertBaseEquals(resting_base, original_base)
end

function test_distance_front_to_front_returns_huge_on_bad_angle()
  -- if the WWg is not facing the right way for the rule to be used
  -- then math.huge is returned.
  local resting_base = build_base("base WWg # 19", 'tile_plain_WWg_40x80')
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x80')
  local base_height = get_depth_base('tile_plain_WWg_40x80')
  moving_base.position['z'] = moving_base.position['z'] - base_height
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = distance_front_to_front(transform_moving, transform_resting)
  lu.assertEquals(actual, math.huge)
end

function test_distance_front_to_front_returns_distance()
  local resting_base = build_base("base Bw # 19")
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  moving_base.setRotation({0,  -180, 0})
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.topright.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.topright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  transform_moving = calculate_transform(moving_base)
    
  local actual = distance_front_to_front(transform_moving, transform_resting)
  lu.assertAlmostEquals(actual, 0.0, 0.01)
end


function test_distance_front_to_left_returns_huge_on_bad_angle()
  -- if the WWg is not facing the right way for the rule to be used
  -- then math.huge is returned.
  local resting_base = build_base("base WWg # 19", 'tile_plain_WWg_40x80')
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x80')
  moving_base.position['x'] = moving_base.position['x'] - g_base_width_inches
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = distance_front_to_left(transform_moving, transform_resting)
  lu.assertEquals(actual, math.huge)
end

function test_distance_front_to_left_returns_distance()
  local resting_base = build_base("base Bw # 19")
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  moving_base.setRotation({0, 90, 0})
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.topleft.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.topleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  transform_moving = calculate_transform(moving_base)
    
  local actual = distance_front_to_left(transform_moving, transform_resting)
  lu.assertAlmostEquals(actual, 0.0, 0.01)
end


function test_distance_front_to_right_returns_huge_on_bad_angle()
  -- if the WWg is not facing the right way for the rule to be used
  -- then math.huge is returned.
  local resting_base = build_base("base WWg # 19", 'tile_plain_WWg_40x80')
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x80')
  moving_base.position['x'] = moving_base.position['x'] + g_base_width_inches
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = distance_front_to_right(transform_moving, transform_resting)
  lu.assertEquals(actual, math.huge)
end

function test_distance_front_to_right_returns_distance()
  local resting_base = build_base("base Bw # 19")
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  moving_base.setRotation({0, -90, 0})
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topright.x - transform_moving.corners.topright.x
  local delta_z = transform_resting.corners.topright.z - transform_moving.corners.topright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  transform_moving = calculate_transform(moving_base)
    
  local actual = distance_front_to_right(transform_moving, transform_resting)
  lu.assertAlmostEquals(actual, 0.0, 0.01)
end

function test_distance_back_to_front_returns_huge_when_angle_too_different()
  local resting_base = build_base("base Bw # 19")
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.botleft.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.botleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  moving_base.setRotation({0, -90, 0})
  transform_moving = calculate_transform(moving_base)
    
  local actual = distance_back_to_front(transform_moving, transform_resting)
  lu.assertEquals(actual, math.huge)
end

function test_distance_back_to_front_returns_distance()
  local resting_base = build_base("base Bw # 19")
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.botleft.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.botleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x   
  moving_base.position['z'] = moving_base.position['z'] + delta_z   
  transform_moving = calculate_transform(moving_base)
    
  local actual = distance_back_to_front(transform_moving, transform_resting)
  lu.assertAlmostEquals(actual, 0.0, 1e-4)
end

function test_snap_to_base_infront()
  -- Setup
  local resting_base = build_base("base Bw # 19")
  local original_base = deep_copy(resting_base)
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.botleft.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.botleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x 
  moving_base.position['z'] = moving_base.position['z'] + delta_z 
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)
    
  -- check that rule applies  
  local actual = distance_back_to_front(transform_moving, transform_resting)
  lu.assertTrue(actual < math.huge)
  
  -- Exercise
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'infront')
  
  -- Verify
  local transform_actual = calculate_transform(moving_base)
  local actual_rotation = transform_actual.rotation
  lu.assertAlmostEquals(actual_rotation, transform_resting.rotation, 0.01)
  lu.assertPointAlmostEquals(transform_actual.corners.botleft, transform_resting.corners.topleft)  
  lu.assertPointAlmostEquals(transform_actual.corners.botright, transform_resting.corners.topright)
  lu.assertBaseEquals(resting_base, original_base)    
end

function test_snap_to_base_behind()
  -- Setup
  local resting_base = build_base("base Bw # 19")
  resting_base.setRotation({0, 0, 0}) 
  local original_base = deep_copy(resting_base)
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.botleft.x - transform_moving.corners.topleft.x
  local delta_z = transform_resting.corners.botleft.z - transform_moving.corners.topleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x 
  moving_base.position['z'] = moving_base.position['z'] + delta_z
  moving_base.setRotation({0, 0, 0}) 
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)
    
  -- check that rule applies  
  local actual = distance_front_to_back(transform_moving, transform_resting)
  lu.assertTrue(actual < math.huge)
  
  -- Exercise
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'behind')
  
  -- Verify
  local transform_actual = calculate_transform(moving_base)
  local actual_rotation = transform_actual.rotation
  lu.assertAlmostEquals(actual_rotation, transform_resting.rotation, 0.01)
  lu.assertPointAlmostEquals(transform_actual.corners.topleft, transform_resting.corners.botleft)  
  lu.assertPointAlmostEquals(transform_actual.corners.topright, transform_resting.corners.botright)  
  lu.assertBaseEquals(resting_base, original_base)
end


function test_snap_to_base_opposite()
  -- Setup
  local resting_base = build_base("base Bw # 19")
  local original_base = deep_copy(resting_base)
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.topright.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.topright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x 
  moving_base.position['z'] = moving_base.position['z'] + delta_z
  moving_base.setRotation({0, 180, 0}) 
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)
    
  -- check that rule applies  
  local actual = distance_front_to_front(transform_moving, transform_resting)
  lu.assertTrue(actual < math.huge)
  
  -- Exercise
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'opposite')
  
  -- Verify
  local transform_actual = calculate_transform(moving_base)
  local actual_rotation = transform_actual.rotation
  lu.assertAlmostEquals(actual_rotation, normalize_radians(transform_resting.rotation+math.pi), 0.01)
  lu.assertPointAlmostEquals(transform_actual.corners.topleft, transform_resting.corners.topright)  
  lu.assertPointAlmostEquals(transform_actual.corners.topright, transform_resting.corners.topleft)  
  lu.assertBaseEquals(resting_base, original_base)
end

function test_snap_to_base_left()
  -- Setup
  local resting_base = build_base("base Bw # 19")
  local original_base = deep_copy(resting_base)
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.topright.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.topright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x
  moving_base.position['z'] = moving_base.position['z'] + delta_z
  moving_base.setRotation({0, 0, 0}) 
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)
    
  -- check that rule applies  
  local actual = distance_left_to_right_side(transform_moving, transform_resting)
  lu.assertTrue(actual < math.huge)
  
  -- Exercise
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'left')
  
  -- Verify
  local transform_actual = calculate_transform(moving_base)
  local actual_rotation = transform_actual.rotation
  lu.assertAlmostEquals(actual_rotation, transform_resting.rotation, 0.01)
  lu.assertPointAlmostEquals(transform_actual.corners.topright, transform_resting.corners.topleft)  
  lu.assertBaseEquals(resting_base, original_base)
end


function test_snap_to_base_right()
  -- Setup
  local resting_base = build_base("base Bw # 19")
  local original_base = deep_copy(resting_base)
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topright.x - transform_moving.corners.topleft.x
  local delta_z = transform_resting.corners.topright.z - transform_moving.corners.topleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x
  moving_base.position['z'] = moving_base.position['z'] + delta_z 
  moving_base.setRotation({0, 0, 0}) 
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)
    
  -- check that rule applies  
  local actual = distance_right_to_left_side(transform_moving, transform_resting)
  lu.assertTrue(actual < math.huge)
  
  -- Exercise
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'right')
  
  -- Verify
  local transform_actual = calculate_transform(moving_base)
  local actual_rotation = transform_actual.rotation
  lu.assertAlmostEquals(actual_rotation, transform_resting.rotation, 0.01)
  lu.assertPointAlmostEquals(transform_actual.corners.topleft, transform_resting.corners.topright)  
  lu.assertBaseEquals(resting_base, original_base)
end

function test_snap_to_base_door_left()
  -- Setup
  local resting_base = build_base("base Bw # 19")
  local original_base = deep_copy(resting_base)
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.topleft.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.topleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x 
  moving_base.position['z'] = moving_base.position['z'] + delta_z 
  moving_base.setRotation({0, 90, 0}) 
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)
    
  -- check that rule applies  
  local actual = distance_front_to_left(transform_moving, transform_resting)
  lu.assertTrue(actual < math.huge)
  
  -- Exercise
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'door_left')
  
  -- Verify
  local transform_actual = calculate_transform(moving_base)
  local actual_rotation = transform_actual.rotation
  lu.assertAlmostEquals(actual_rotation, normalize_radians(transform_resting.rotation-(math.pi/2)), 0.01)
  lu.assertPointAlmostEquals(transform_actual.corners.topleft, transform_resting.corners.topleft)  
  lu.assertBaseEquals(resting_base, original_base)
end


function test_snap_to_base_door_right()
  -- Setup
  local resting_base = build_base("base Bw # 19")
  local original_base = deep_copy(resting_base)
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topright.x - transform_moving.corners.topright.x
  local delta_z = transform_resting.corners.topright.z - transform_moving.corners.topright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x 
  moving_base.position['z'] = moving_base.position['z'] + delta_z
  moving_base.setRotation({0, -90, 0}) 
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)
    
  -- check that rule applies  
  local actual = distance_front_to_right(transform_moving, transform_resting)
  lu.assertTrue(actual < math.huge)
  
  -- Exercise
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'door_right')
  
  -- Verify
  local transform_actual = calculate_transform(moving_base)
  local actual_rotation = transform_actual.rotation
  lu.assertAlmostEquals(actual_rotation, normalize_radians(transform_resting.rotation+(math.pi/2)), 0.01)
  lu.assertPointAlmostEquals(transform_actual.corners.topright, transform_resting.corners.topright)  
  lu.assertBaseEquals(resting_base, original_base)
end

function test_snap_to_base_left_to_wwg_back()
  local resting_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  resting_base.setRotation({0, 90, 0}) 
  local expected_resting = deep_copy(resting_base)
  
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base Bw # 19")
  moving_base.setRotation({0, 0, 0}) 
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.botright.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.botright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x 
  moving_base.position['z'] = moving_base.position['z'] + delta_z  
  local expected_moving = deep_copy(moving_base)
  
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)
    
  -- check that rule applies  
  local actual = distance_back_to_left(transform_moving, transform_resting)
  lu.assertTrue(actual < math.huge)
  
  -- Exercise
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'left_to_wwg_back')
  
  -- Verify
  lu.assertBaseEquals(moving_base, expected_moving)
  lu.assertBaseEquals(resting_base, expected_resting)
end

function test_snap_to_base_left_to_wwg_front()
  local resting_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  resting_base.setRotation({0, 270, 0}) 
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base Bw # 19")
  moving_base.setRotation({0, 180, 0}) 
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topleft.x - transform_moving.corners.topleft.x
  local delta_z = transform_resting.corners.topleft.z - transform_moving.corners.topleft.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x 
  moving_base.position['z'] = moving_base.position['z'] + delta_z 
  jiggle(moving_base)  
  transform_moving = calculate_transform(moving_base)
    
  -- check that rule applies  
  local actual = distance_back_to_left(transform_moving, transform_resting)
  lu.assertTrue(actual < math.huge)
  
  -- Exercise
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'left_to_wwg_front')
  
  -- Verify
  local transform_actual = calculate_transform(moving_base)
  lu.assertAlmostEquals(moving_base.rotation.y, 180, 0.01)
  lu.assertPointAlmostEquals(transform_actual.corners.topleft, transform_resting.corners.topleft)  
end

function test_right_to_wwg_back()
  local resting_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base Bw # 19")
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.botleft.x - transform_moving.corners.topright.x
  local delta_z = transform_resting.corners.botleft.z - transform_moving.corners.topright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x 
  moving_base.position['z'] = moving_base.position['z'] + delta_z 
  moving_base.setRotation({0, -90, 0}) 
  jiggle(moving_base)
  transform_moving = calculate_transform(moving_base)
    
  -- check that rule applies  
  local actual = distance_right_to_back(transform_moving, transform_resting)
  lu.assertTrue(actual < math.huge)
  
  -- Exercise
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'right_to_wwg_back')
  
  -- Verify
  local transform_actual = calculate_transform(moving_base)
  local actual_rotation = transform_actual.rotation
  lu.assertAlmostEquals(actual_rotation, normalize_radians(transform_resting.rotation+(math.pi*0.5)), 0.01)
  lu.assertPointAlmostEquals(transform_actual.corners.topright, transform_resting.corners.botleft)  
end


function test_right_to_wwg_front()
  local resting_base = build_base("base WWg # 20", 'tile_plain_WWg_40x40')
  resting_base.setRotation({0, 270, 0}) 
  local transform_resting = calculate_transform(resting_base)
  
  local moving_base = build_base("base Bw # 19")
  moving_base.setRotation({0, 0, 0}) 
  local transform_moving = calculate_transform(moving_base)
  local delta_x = transform_resting.corners.topright.x - transform_moving.corners.topright.x
  local delta_z = transform_resting.corners.topright.z - transform_moving.corners.topright.z
  moving_base.position['x'] = moving_base.position['x'] + delta_x 
  moving_base.position['z'] = moving_base.position['z'] + delta_z 
  jiggle(moving_base)  
  transform_moving = calculate_transform(moving_base)
    
  -- check that rule applies  
  local actual = distance_right_to_front(transform_moving, transform_resting)
  lu.assertTrue(actual < math.huge)
  
  -- Exercise
  snap_to_base(moving_base, transform_moving, resting_base, transform_resting, 'right_to_wwg_front')
  
  -- Verify
  local transform_actual = calculate_transform(moving_base)
  lu.assertAlmostEquals(moving_base.getRotation().y, 0, 0.01)
  lu.assertPointAlmostEquals(transform_actual.corners.topright, transform_resting.corners.topright)  
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

function test_is_base_returns_false_for_nil()
  lu.assertFalse( is_base(nil) )
end

function test_is_base_returns_false_if_name_is_nil()
  local base = { getName = function() return nil end }
  lu.assertFalse( is_base(base) )
end

function test_is_base_returns_false_if_name_not_starting_with_base()
  local base = { getName = function() return "abase" end }
  lu.assertFalse( is_base(base) )
end

function test_is_base_returns_true_if_name_starting_with_base()
  local base = { getName = function() return "base bow" end }
  lu.assertTrue( is_base(base) )
end

os.exit( lu.LuaUnit.run() )

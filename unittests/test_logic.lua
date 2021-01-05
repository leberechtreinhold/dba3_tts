lu = require('externals/luaunit/luaunit')
require('scripts/data/data_settings')
require('scripts/logic')
require('scripts/utilities')

if g_bases == nil then
  g_bases = {}
end

-- Create a fake base that can be used for
-- testing
function build_base(base_name)
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
  base['getRotation']=function()
    return base.rotation
  end

  local tile="tile_plain_4Bw_40x20"

  g_bases[ base_name] = {
    tile=tile,
    is_red_player=true
  }

  if _G [tile] == nil then
    _G[tile]={ depth=20  }
  end

  return base
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

-- front and back bases edges are the touching
function test_is_behind_returns_true()
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

function test_is_behind_returns_false_if_unit_is_too_far_behind()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be behind the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_depth = get_size(resting_base.getName())['z']
  local threshold = g_max_corner_distance_snap^0.5
  moving_base.position['z'] = resting_base.position['z'] - (base_depth + threshold)
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = is_behind(transform_moving, transform_resting)
  lu.assertFalse(actual) 
end

function test_is_behind_returns_true_if_unit_is_close_behind()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be behind the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_depth = get_size(resting_base.getName())['z']
  local under_threshold = (g_max_corner_distance_snap^0.5) - 0.1
  moving_base.position['z'] = resting_base.position['z'] - (base_depth + under_threshold)
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = is_behind(transform_moving, transform_resting)
  lu.assertTrue(actual) 
end

-- moving unit is on-top of the resting unit
function test_is_behind_returns_true_if_unit_is_close_intersect()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be behind the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_depth = get_size(resting_base.getName())['z']
  local under_threshold = (g_max_corner_distance_snap^0.5) - 0.1
  moving_base.position['z'] = resting_base.position['z'] - (base_depth - under_threshold)
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = is_behind(transform_moving, transform_resting)
  lu.assertTrue(actual) 
end

-- moving unit is on-top of the resting unit
function test_is_behind_returns_false_if_unit_is_far_intersect()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be behind the resting base
  moving_base.position = shallow_copy(resting_base.position)

  local base_depth = get_size(resting_base.getName())['z']
  local threshold = g_max_corner_distance_snap^0.5
  moving_base.position['z'] = resting_base.position['z'] - (base_depth - threshold)  
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = is_behind(transform_moving, transform_resting)
  lu.assertFalse(actual) 
end

function test_is_behind_returns_false_if_tl_too_far()
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
  local actual = is_behind(transform_moving, transform_resting)
  lu.assertFalse(actual) 
end

function test_is_behind_returns_false_if_tr_too_far()
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
  local actual = is_behind(transform_moving, transform_resting)
  lu.assertFalse(actual) 
end

function test_is_behind_returns_false_if_tl_too_far_on_intersect()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be behind the resting base, but skewed
  -- with one corner within the threshold and one corner more than the 
  -- threshold
  moving_base.position = shallow_copy(resting_base.position)
  moving_base['rotation']['y']= g_max_angle_pushback_rad

  local base_depth = get_size(resting_base.getName())['z']
  local threshold = (g_max_corner_distance_snap^0.5) 
  moving_base.position['z'] = resting_base.position['z'] - (base_depth - 2*threshold)
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = is_behind(transform_moving, transform_resting)
  lu.assertFalse(actual) 
end

function test_is_behind_returns_false_if_tr_too_far_on_intersect()
  local resting_base = build_base("base 4Bw # 16")
  local moving_base = build_base("base 4Bw # 17")
  -- have the moving base be behind the resting base, but skewed
  -- with one corner within the threshold and one corner more than the 
  -- threshold
  moving_base.position = shallow_copy(resting_base.position)
  moving_base['rotation']['y']= g_max_angle_pushback_rad

  local base_depth = get_size(resting_base.getName())['z']
  local threshold = (g_max_corner_distance_snap^0.5) 
  moving_base.position['z'] = resting_base.position['z'] - (base_depth - threshold)
  local transform_resting = calculate_transform(resting_base)
  local transform_moving = calculate_transform(moving_base)
  local actual = is_behind(transform_moving, transform_resting)
  lu.assertFalse(actual) 
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

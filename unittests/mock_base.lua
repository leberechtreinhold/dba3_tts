require('scripts/data/data_settings')
require('scripts/data/data_tables')
require('scripts/data/data_terrain')
require('scripts/data/data_troops')
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
lu = require('externals/luaunit/luaunit')

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

-- Create a fake base that can be used for
-- testing, based on another base
function copy_base(orig)
  local copy = {}
  copy['tile'] = orig['tile']
  local base = {
    name=orig.name,
    position=deep_copy(orig.position),
    rotation=deep_copy(orig.rotation),
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

  return base
end

-- slightly disturb the base position and rotation so we can
-- check that snapping works.
function jiggle(base)
  local position = base.getPosition()
  position['x'] = position['x'] + 0.15
  position['z'] = position['z'] + 0.2
  base.setPosition(position)
  
  local rotation = base.getRotation()
  rotation['y'] = rotation['y'] + 5
  base.setRotation(rotation)
end
  

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
  lu.assertPointAlmostEquals(a.getRotation(), b.getRotation())
  local a_pos = a.getPosition()
  local b_pos = b.getPosition()
  lu.assertPointAlmostEquals(a_pos, b_pos)
end



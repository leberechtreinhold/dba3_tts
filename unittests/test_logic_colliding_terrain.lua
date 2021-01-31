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

-- Simulate TTS function
Player={}
Player.getPlayers = function()
  return { {color="Red"}, {color="Blue"} }
end

function test_terrain_not_invisible_if_colliding_with_not_base()
  local tree1_invisible = {}
  local tree1_registered = nil
  local tree1 = {
      getName = function() return 'tree1' end,
      getGUID = function() return 'tree1guid' end,
      registerCollisions = function(stay)
          tree1_registered = stay
        end,
      setInvisibleTo = function(players) tree1_invisible = players end,
      }
  local tree2 = {
    getName = function() return 'tree2' end,
    getGUID = function() return 'tree2guid' end,
  }
  register_obscurring_terrain(tree1)
  lu.assertEquals(false, tree1_registered)

  -- Exercise
  g_hide_obscurring_terrain = true
  local info = { collision_object=tree2 }
  onObjectCollisionEnter(tree1, info)

  -- verify
  lu.assertTrue(is_table_empty(tree1_invisible))
end

function test_terrain_invisible_if_colliding_with_base()
  local tree1_invisible = {}
  local tree1 = {
      getName = function() return 'tree' end,
      getGUID = function() return 'guidtree' end,
      registerCollisions = function(stay) end,
      setInvisibleTo = function(players) tree1_invisible = players end,
    }
  local bow = {
    getName = function() return 'base bow' end,
    getGUID = function() return 'guidbow' end
   }
  register_obscurring_terrain(tree1)

    -- Exercise
    g_hide_obscurring_terrain = true

  local info = { collision_object=bow }
  onObjectCollisionEnter(tree1, info)

  -- Validate
  lu.assertFalse(is_table_empty( tree1_invisible ) )
end

function test_terrain_visible_if_colliding_with_base_if_obscurring_terrain_disabled()
  local tree1_invisible = {}
  local tree1 = {
      getName = function() return 'tree' end,
      getGUID = function() return 'guidtree' end,
      registerCollisions = function(stay) end,
      setInvisibleTo = function(players) tree1_invisible = players end,
    }
  local bow = {
    getName = function() return 'base bow' end,
    getGUID = function() return 'guidbow' end
   }
  register_obscurring_terrain(tree1)

  -- Exercise
  g_hide_obscurring_terrain = false
  local info = { collision_object=bow }
  onObjectCollisionEnter(tree1, info)

  -- Validate
  lu.assertTrue(is_table_empty( tree1_invisible ) )
end


function test_terrain_visible_if_base_leaves()
  local tree1_invisible = {}
  local tree1 = {
      getName = function() return 'tree' end,
      getGUID = function() return 'guidtree' end,
      registerCollisions = function(stay) end,
      setInvisibleTo = function(players) tree1_invisible = players end,
    }
  local bow = {
    getName = function() return 'base bow' end,
    getGUID = function() return 'guidbow' end
   }
  register_obscurring_terrain(tree1)

  -- Exercise
  g_hide_obscurring_terrain = true
  local info = { collision_object=bow }
  onObjectCollisionEnter(tree1, info)
  lu.assertFalse(is_table_empty( tree1_invisible ) )
  onObjectCollisionExit(tree1, info)

  -- verify
  lu.assertTrue(is_table_empty( tree1_invisible ) )
end

function test_terrain_visible_if_base_leaves_after_multiple_entries()
  local tree1_invisible = {}
  local tree1 = {
      getName = function() return 'tree' end,
      getGUID = function() return 'guidtree' end,
      registerCollisions = function(stay) end,
      setInvisibleTo = function(players) tree1_invisible = players end,
    }
  local bow = {
    getName = function() return 'base bow' end,
    getGUID = function() return 'guidbow' end
  }
  register_obscurring_terrain(tree1)

  -- Exercise
  g_hide_obscurring_terrain = true
  local info = { collision_object=bow }
  onObjectCollisionEnter(tree1, info)
  onObjectCollisionEnter(tree1, info)
  onObjectCollisionEnter(tree1, info)
  onObjectCollisionExit(tree1, info)
  lu.assertTrue(is_table_empty( tree1_invisible ) )
end

function test_non_terrain_ignored_for_collision_enter()
  local bow = {
    getName = function() return 'base bow' end,
    getGUID = function() return "guidbow" end
  }
  local aux = {
    getName = function() return 'base aux' end,
    getGUID = function() return "guidaux" end
  }

  -- Exercise
  g_hide_obscurring_terrain = true
  local info = { collision_object=bow }
  onObjectCollisionEnter(aux, info)
end

function test_non_terrain_ignored_for_collision_exit()
  local bow = {
    getName = function() return 'base bow' end,
    getGUID = function() return "guidbow" end
  }
  local aux = {
    getName = function() return 'base aux' end,
    getGUID = function() return "guidaux" end
  }
  -- Exercise
  g_hide_obscurring_terrain = true
  local info = { collision_object=bow }
  onObjectCollisionExit(aux, info)
end

-- set the visibility of the terrain based on collisions with bases.
-- Used when loading a saved game.
function test_set_obscurring_terrain_visibility_hidden()
-- Setup
  local tree1_invisible = {}
  local tree1 = {
      getName = function() return 'tree' end,
      getGUID = function() return 'guidtree' end,
      registerCollisions = function(stay) end,
      setInvisibleTo = function(players) tree1_invisible = players end,
    }
  local bow = {
    getName = function() return 'base bow' end,
    getGUID = function() return 'guidbow' end
   }
  register_obscurring_terrain(tree1)

  g_hide_obscurring_terrain = true
  local info = { collision_object=bow }
  onObjectCollisionEnter(tree1, info)

  getObjectFromGUID =function(guid)
    if guid == "guidtree" then
      return tree1
    end
    lu.assertFalse(true)  -- test failed
  end

  -- Exercise
  tree1_invisible = {}
  set_obscurring_terrain_visibility('guidtree')

  -- Verify
  lu.assertFalse(is_table_empty( tree1_invisible ) )

  -- Cleanup
  getObjectFromGUID = nil
end

-- set the visibility of the terrain based on collisions with bases.
-- Used when loading a saved game.
function test_set_obscurring_terrain_visibility_visible()
-- Setup
  local tree1_invisible = {}
  local tree1 = {
      getName = function() return 'tree' end,
      getGUID = function() return 'guidtree' end,
      registerCollisions = function(stay) end,
      setInvisibleTo = function(players) tree1_invisible = players end,
    }
  local bow = {
    getName = function() return 'base bow' end,
    getGUID = function() return 'guidbow' end
   }
  register_obscurring_terrain(tree1)

  g_hide_obscurring_terrain = false -- tesing setting
  local info = { collision_object=bow }
  onObjectCollisionEnter(tree1, info)

  getObjectFromGUID =function(guid)
    if guid == "guidtree" then
      return tree1
    end
    lu.assertFalse(true)  -- test failed
  end

  -- Exercise
  tree1_invisible = {}
  set_obscurring_terrain_visibility('guidtree')

  -- Verify
  lu.assertTrue(is_table_empty( tree1_invisible ) )

  -- Cleanup
  getObjectFromGUID = nil
end

--function test_g_hide_obscurring_terrain_loaded_as_false()
--  g_hide_obscurring_terrain = false
--  local saved = save_game()
--  lu.assertEquals( type(saved), "string")
--  g_hide_obscurring_terrain = true
--  load_saved_game(saved)
--  lu.assertFalse(g_hide_obscurring_terrain)
--end

os.exit( lu.LuaUnit.run() )

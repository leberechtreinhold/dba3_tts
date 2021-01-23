package.path="?.lua;?.ttslua"

lu = require('externals/luaunit/luaunit')
require('scripts/data/data_settings')
require('scripts/base_cache')
require('scripts/logic')
require('scripts/utilities')
require('scripts/utilities_lua')

if g_bases == nil then
  g_bases = {}
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

  if _G [tile] == nil then
    _G[tile]={ depth=20  }
  end

  return base
end

function test_get_base()
  local expected = build_base("base 4Bw # 16")
  local actual = build_base_cache(expected)
  lu.assertEquals(actual.getBase(), expected)
end

function test_is_wwg()
  local expected = build_base("base 4Bw # 16")
  local sut = build_base_cache(expected)
  lu.assertFalse( sut['is_wwg'] )
end

function test_is_wwg()
  local expected = build_base("base 4Bw # 16")
  local sut = build_base_cache(expected)
  lu.assertFalse( sut['is_large_base'] )
end

function test_get_name()
  local expected = "base 4Bw # 16"
  local base = build_base(expected)
  local sut = build_base_cache(base)
  local actual = sut.getName()
  lu.assertEquals(actual, expected)
end

function test_get_position()
  local base = build_base("base 4Bw # 16")
  local sut = build_base_cache(base)
  lu.assertEquals(sut.getPosition(), base.getPosition())
end

function test_get_rotation()
  local base = build_base("base 4Bw # 16")
  local sut = build_base_cache(base)
  lu.assertEquals(sut.getRotation(), base.getRotation())
end

function test_get_size()
  local name="base 4Bw # 16"
  local base = build_base(name)
  local sut = build_base_cache(base)
  local expected = get_size(name)
  local actual = sut.getSize()
  lu.assertEquals(actual, expected)
end

function test_get_transform()
  local expected_base = build_base("base 4Bw # 16")
  local sut = build_base_cache(expected_base)
  local expected_transform = calculate_transform(expected_base)
  local actual = sut.getTransform()
  lu.assertEquals(actual, expected_transform)
end

function test_get_corners()
  local expected_base = build_base("base 4Bw # 16")
  local sut = build_base_cache(expected_base)
  local expected_transform = calculate_transform(expected_base)
  local expected_corners = expected_transform['corners']
  local actual = sut.getCorners()
  lu.assertEquals(actual, expected_corners)
end

function test_get_shape()
  local expected_base = build_base("base 4Bw # 16")
  local sut = build_base_cache(expected_base)
  local expected_transform = calculate_transform(expected_base)
  local expected_shape = transform_to_shape( expected_transform )
  local actual = sut.getShape()
  lu.assertEquals(actual, expected_shape)
end

function test_intersects_with()
  local other_name = "base 4Bw # 16"
  local other_base = build_base(other_name)
  local other = build_base_cache(other_base)
  local name = "base 4Bw # 15"
  local base = build_base(name)
  local sut = build_base_cache(base)
  local actual = sut.intersectsWith(other)
  lu.assertTrue(actual)
end

--function test_table_print()
--  local expected_base = build_base("base 4Bw # 16")
--  local sut = build_base_cache(expected_base)
--  sut.getTransform()
--  table_print(sut)
--end


os.exit( lu.LuaUnit.run() )

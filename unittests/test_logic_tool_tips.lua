lu = require('externals/luaunit/luaunit')
require('scripts/utilities_lua')
require('scripts/utilities')
require('scripts/logic_tool_tips')
require('scripts/data/data_cheat_sheet')

function assert_has_substring(str, sub)
  if str_has_substr(str, sub) then
    return
  end
  print("substring ", sub, " not in ", str)
  lu.assertFalse(true)
end

function test_join_tip_lines_returns_empty_string_for_nil()
  local actual = join_tip_lines("header", nil)
  lu.assertEquals(actual, "")
end

function test_join_tip_lines_returns_empty_string_for_empty_table()
  local actual = join_tip_lines("header", {})
  lu.assertEquals(actual, "")
end

function test_join_tip_lines_returns_1_line_for_1_entry()
  local actual = join_tip_lines("\nchants:", {'Down with Rome'})
  lu.assertEquals(actual, "\nchants: Down with Rome")
end

function test_join_tip_lines_returns_list()
  local actual = join_tip_lines("\nchants:", {'Down with Rome', 'Up with Sparticat'})
  lu.assertEquals(actual, "\nchants:\n- Down with Rome\n- Up with Sparticat")
end

function test_tip_is_nill_for_bad_base_type()
  local actual = build_tool_tip("garbage")
  lu.assertEquals(actual, nil)
end

function test_tip_includes_unit_name()
  local actual = build_tool_tip("3Bw")
  assert_has_substring(actual, "Fast Bows")
end

function test_tip_includes_movement()
  local actual = build_tool_tip("4Bd")
  assert_has_substring( actual, "2BW/1BW")
end

function test_tip_includes_combat()
  local actual = build_tool_tip("4Bd")
  assert_has_substring( actual, "5/3/4")
end

function test_tip_includes_combat_shot_at_same_as_foot()
  local actual = build_tool_tip("3Bw")
  assert_has_substring( actual, "2/4/2")
end

function test_tip_includes_combat_notes()
  local actual = build_tool_tip("3Kn")
  assert_has_substring(actual, "recoils 4Kn on an equal score")
end

function test_tip_includes_can_quick_kill()
  local actual = build_tool_tip("3Kn")
  assert_has_substring(actual, "Ps in Good Going")
end

function test_tip_includes_makes_flee()
  local actual = build_tool_tip("3Bw")
  assert_has_substring(actual, "SCh")
end

function test_tip_includes_quick_killed_by()
  local actual = build_tool_tip("El")
  assert_has_substring(actual, "shooting Art")
end

function test_tip_includes_flees_from()
  local actual = build_tool_tip("SCh")
  assert_has_substring(actual, "shooting enemy")
end

function test_tip_includes_cannot_destroy()
  local actual = build_tool_tip("El")
  assert_has_substring(actual, "Ps recoil")
end

function test_tip_includes_movement_notes()
  local actual = build_tool_tip("3Kn")
  assert_has_substring(actual, "friendly Ps when moving")
end

function test_every_type_formats_to_string()
  for base_type, _ in pairs(base_tool_tips) do
    local result = build_tool_tip(base_type)
    lu.assertEquals(type(result), "string")
  end
end

function test_get_base_type_from_name()
  local actual = get_base_type_from_name("base WWg # 20")
  lu.assertEquals(actual, "WWg")
end

function test_get_base_type_from_name_removes_general()
  local actual = get_base_type_from_name("base WWg_Gen # 20")
  lu.assertEquals(actual, "WWg")
end


function test_get_base_type_from_name_returns_nil_on_bad_format()
  local actual = get_base_type_from_name("WWg_Gen # 20")
  lu.assertEquals(actual, nil)
end

function test_get_tool_tip_for_base_name_returns_nil_for_nil()
  local actual = get_tool_tip_for_base_name(nil)
  lu.assertEquals(actual, nil)
end

function test_get_tool_tip_for_base_name_returns_nil_for_malformed_name()
  local actual = get_tool_tip_for_base_name("fred")
  lu.assertEquals(actual, nil)
end


function test_get_tool_tip_for_base_name()
  local actual = get_tool_tip_for_base_name("base 4Bw # 2")
  assert_has_substring( actual, "2/4/2")
end


os.exit( lu.LuaUnit.run() )

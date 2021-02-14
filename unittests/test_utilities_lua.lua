lu = require('externals/luaunit/luaunit')
require('scripts/utilities_lua')

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

function test_str_trim_returns_original_string()
  local expected = "abc      def"
  local actual = str_trim(expected)
  lu.assertEquals(actual, expected)
end

function test_str_trim_removes_leading_spaces()
  local expected = "abc      def"
  local actual = str_trim("  " .. expected)
  lu.assertEquals(actual, expected)
end

function test_str_trim_removes_trailing_spaces()
  local expected = "abc      def"
  local actual = str_trim("  " .. expected)
  lu.assertEquals(actual, expected)
end

function test_str_remove_prefix_returns_original_string()
  local actual=str_remove_prefix("something", "delta")
  lu.assertEquals(actual, "something")
end

function test_str_remove_prefix()
  local actual=str_remove_prefix("something", "some")
  lu.assertEquals(actual, "thing")
end

function test_str_remove_suffix_returns_original_string()
  local actual=str_remove_suffix("something", "delta")
  lu.assertEquals(actual, "something")
end

function test_str_remove_suffix()
  local actual=str_remove_suffix("4Bd_Gen", "_Gen")
  lu.assertEquals(actual, "4Bd")
end

function test_str_join_returns_empty_string()
  local actual = str_join("foo", {})
  lu.assertEquals(actual, "")
end

function test_str_join_returns_table_value()
  local actual = str_join("foo", {"value"})
  lu.assertEquals(actual, "value")
end

function test_str_join_returns_table_values()
  local actual = str_join("foo", {42,34})
  lu.assertEquals(actual, "42foo34")
end


os.exit( lu.LuaUnit.run() )

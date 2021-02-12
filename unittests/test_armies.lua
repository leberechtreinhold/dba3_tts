lu = require('externals/luaunit/luaunit')
function dofile (filename)
  local f = assert(loadfile(filename))
  return f()

end
armies={}
dofile("../scripts/data/data_armies_book_I.ttslua")
dofile("../scripts/data/data_armies_book_II.ttslua")
dofile("../scripts/data/data_armies_book_III.ttslua")
dofile("../scripts/data/data_armies_book_IV.ttslua")

local function starts_with(str, start)
   return str:sub(1, #start) == start
end

local function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end


function remove_suffix(s, suffix)
    return s:gsub("%" .. suffix, "")
end

function normalize_base_name(name)
  name = remove_suffix(name, "_Gen")
  return name
end

function assert_base_name_valid(name, army_name)
  local valid= {}
  -- Elephants
  valid['El']=true
  -- Knights
  valid['3Kn']=true 
  valid['4Kn']=true 
  valid['6Kn']=true 
  valid['HCh']=true
  -- Cavalry
  valid['Cv']=true 
  valid['6Cv']=true 
  valid['LCh']=true
  -- Light Horse
  valid['LH']=true 
  valid['LCm']=true 
  -- Scythed Chariots
  valid['SCh']=true
  -- Camelry
  valid['Cm']=true
  -- Spears
  valid['Sp']=true 
  valid['8Sp']=true
  -- Pikes
  valid['4Pk']=true 
  valid['3Pk']=true
  -- Blades
  valid['4Bd']=true 
  valid['3Bd']=true 
  valid['6Bd']=true
  -- Auxilia
  valid['4Ax']=true
  valid['3Ax']=true
  -- Bows
  valid['4Bw']=true
  valid['3Bw']=true 
  valid['8Bw']=true
  valid['4Cb']=true 
  valid['3Cb']=true 
  valid['8Cb']=true
  valid['4Lb']=true 
  valid['3Lb']=true 
  valid['8Lb']=true
  valid['Mtd-3Bw']=true 
  valid['Mtd-4Bw']=true 
  valid['Mtd-4Cb']=true
  valid['Mtd-4Lb']=true 
  -- Psiloi
  valid['Ps']=true
  -- Warbands
  valid['4Wb']=true
  valid['3Wb']=true
  -- Hordes
  valid['7Hd']=true 
  valid['5Hd']=true
  -- Artillery
  valid['Art']=true
  -- War Wagons
  valid['WWg']=true
  -- Ceneral
  valid['CP']=true 
  valid['3CP']=true 
  valid['Lit']=true 
  valid['CWg']=true
  valid['Camp']=true

  local n_name = normalize_base_name(name)
  if valid[n_name] then
    return
  end
  print("Invalid name ", name, " ", n_name)
  print(army_name)
  lu.assertTrue(false)
end

-- page 7 lists the abbreviations for the bases.  Verify only the correct
-- abbreviations are used in the army lists.
function test_bases_are_in_list()
  for book_name, book in pairs(armies) do
    for army_name, army in pairs(armies[book_name]) do
      for k,v in pairs(army) do
        if starts_with(k, "base") then
          local name = v.name
          assert_base_name_valid(name, army_name)
        end
      end
    end
  end
end

os.exit( lu.LuaUnit.run() )

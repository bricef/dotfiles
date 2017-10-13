
CONFIG_DIR = os.getenv("HOME").."/.timelog"
TIMELOG_DIR = CONFIG_DIR.."/logs"
ACTIVITIES_FILE = CONFIG_DIR.."/activities.txt"



hs.notify.new({title="Hammerspoon", informativeText="Config file load"}):send()

function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

--
-- Force config reload with ⌘ -⌥ - ^ - R
--
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)

--
-- Reload Config files when changed
--
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

--
-- Utility functions
--
string.split = function(str, sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  str:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

table.filter = function(t, filterIter)
  local out = {}

  for k, v in pairs(t) do
    if filterIter(v, k, t) then out[k] = v end
  end

  return out
end

--
-- Launch xmenu on cmd-]
-- 
hs.hotkey.bind({"cmd"}, "]", function()
  function cb(exitCode, stdout, stderr) 
    return exitCode 
  end 
  tk = hs.task.new(
		"/Users/brice/Code/xmenu/bin/xmenu", 
		cb, 
		string.split("-b -H 45 -fs 28 -p ➤ -sb #ff0000 -sf #ffffff", " ")
	)
	tk:setInput("hello\nworld")
	tk:start()
end)

--
-- TODO: Order and deduplicate
--
-- function loadChoicesFromIndex()
--   local choices = {}
--   if file_exists(ACTIVITIES_FILE) then
--     for line in io.lines(ACTIVITIES_FILE) do
--       table.insert(choices, {
--         text=line,
--         -- subText = ,
--         -- image = hs.image(),
--         -- command = ""
--       })
--     end
--   end
--   return choices
-- end

-- function saveTimeLogEntry(entryTable)
--   -- choice.text, choice.command, choice.subText, choice.image
--   local prefix = os.date("[%Y-%m-%d %H:%M]: ")
--   local filename = TIMELOG_DIR.."/"..os.date("%F")..".log"
--   local file = io.open(filename , "a")
--   file:write(prefix..entryTable["text"].."\n")
--   print(prefix..entryTable["text"])
--   file:close()
-- end

-- function saveActivity(activity)
--   local file = io.open(ACTIVITIES_FILE , "a")
--   file:write(activity.."\n")
--   file:close()
-- end

--
-- Launch command menu on cmd-\
--
-- hs.hotkey.bind({"cmd"}, "\\", function()
--   local currentQuery = ""
--   local choices = loadChoicesFromIndex()
  
--   function completionFn(choice)
--     if choice then
--       saveTimeLogEntry(choice)
--       saveActivity(choice["text"])
-- 		else
-- 			print("NO VALID CHOICE MADE")
-- 		end
--   end

--   c = hs.chooser.new(completionFn)
  

--   function onQueryChange(queryString)
--     currentQuery = queryString
--     c:refreshChoicesCallback()
--   end

--   function entryFromQueryString(queryString)
--     entry = {
--       text=queryString
--     }
--     return entry
--   end
  
--   function generateChoices()
--     print("Current query:"..currentQuery)
--     t = table.filter(choices, function(item) return string.find(item["text"], currentQuery) end)
--     if string.len(currentQuery) ~= 0 then
--       table.insert(t, 1, entryFromQueryString(currentQuery))
--     end
--     return t
--   end

--   c:searchSubText(true)
--   c:queryChangedCallback(onQueryChange)
--   c:choices(generateChoices)
--   c:bgDark(false)

--   c:show()

-- end)


hs.hotkey.bind({"cmd"}, "\\", function() 
  function cb(exitCode, stdout, stderr) 
    print("Task Ended")
    print(stdout)
    print(stderr)
    return exitCode 
  end 
  tk = hs.task.new(
		"/Users/brice/repos/timelogger.git/logtime.sh", 
    cb
	)
  print("Task Started")
	tk:start()
end)
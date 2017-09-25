
hs.notify.new({title="Hammerspoon", informativeText="Config file load"}):send()

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
-- Launch command menu on cmd-\
--
hs.hotkey.bind({"cmd"}, "\\", function()
  local currentQuery = ""
  local choices = {
    {
      text="hello",
      subText="A dummy entry to test things out."
      --image=hs.image()
    },
    {
      text="world",
      subText="Another entry"
    }
  }
  
  function completionFn(itemTable)
		if itemTable then
    	print(itemTable["text"])
		else
			print("NO VALID CHOICE MADE")
		end
  end

  c = hs.chooser.new(completionFn)
  

  function onQueryChange(queryString)
    currentQuery = queryString
    c:refreshChoicesCallback()
  end
  
  function generateChoices()
    print("Current query:"..currentQuery)
    return table.filter(choices, function(item) return string.find(item["text"], currentQuery) end)
  end

  c:searchSubText(true)
  c:queryChangedCallback(onQueryChange)
  c:choices(generateChoices)

  c:show()

end)


hs.notify.new({title="Hammerspoon", informativeText="Config file loaded"}):send()

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
function split(str, sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  str:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end


-- 
-- Launch xmenu on cmd-\
-- 
hs.hotkey.bind({"cmd"}, "\\", function()
  function cb(exitCode, stdout, stderr) 
    return exitCode 
  end 
  tk = hs.task.new(
		"/Users/brice/Code/xmenu/bin/xmenu", 
		cb, 
		split("-b -H 45 -fs 28 -p ➤ -sb #ff0000 -sf #ffffff", " ")
	)
	tk:setInput("hello\nworld")
	tk:start()
  
end)

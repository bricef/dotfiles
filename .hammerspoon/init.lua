
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
-- Timelogger on a single shortcut 
-- 
hs.hotkey.bind({"cmd"}, "\\", function()
  function cb(exitCode, stdout, stderr) 
    print("Task Ended")
    print(stdout)
    print(stderr)
    return exitCode 
  end 
  tk = hs.task.new(
		"/Users/brice/repos/timelogger.git/client/logtime.sh", 
		cb 
	)
  print("Task Started")
	tk:start()
end)



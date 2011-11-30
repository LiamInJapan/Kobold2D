require "wax.helpers.bit"
require "wax.helpers.callback"
require "wax.helpers.frame"
require "wax.helpers.base64"
require "wax.helpers.time"
require "wax.helpers.cache"
require "wax.helpers.autoload"
require "wax.helpers.WaxServer"

-- Just a bunch of global helper functions

function IBOutlet(...)
  -- does nothing... just used so we can parse it
end

function wax.alert(title, message, ...)
  local alert = UIAlertView:init()
  alert:setTitle(title)
  alert:setMessage(message)
  
  if not ... then
    alert:addButtonWithTitle("OK")
  else
    for i, name in ipairs{...} do
      alert:addButtonWithTitle(name)
    end
  end
  
  alert:show()
  
  return alert
end

-- -- Forces print to use NSLog
-- function print(obj)
--   -- if there is an error, ignore it
--   pcall(function() wax.print(tostring(obj)) end)
-- end

function puts(obj, ...)
  if type(obj) == "table" then 
    print(table.tostring(obj))
    return
  end
  
  if ... then obj = string.format(tostring(obj), ...) end
  
  print(obj)
end

function wax.guid()
  return NSProcessInfo:processInfo():globallyUniqueString()
end

function wax.eval(input)
  return pcall(function()
    if not input:match("=") then 
      input = "do return (" .. input .. ") end"
    end
    
    local code, err = loadstring(input, "REPL")
    if err then
      error("Syntax Error: " .. err)
    else
      puts(code())
    end
  end)
end

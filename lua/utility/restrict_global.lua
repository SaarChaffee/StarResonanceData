function DeclareGlobal(name, initValue)
  rawset(_G, name, initValue or false)
end

function GetGlobal(name)
  return rawget(_G, name)
end

setmetatable(_G, {
  __newindex = function(table, key, value)
    logError("Attempt to write to undeclared global variable: " .. key)
  end
})

local savedVariablesPath = assert(arg[1], "usage: lua scripts/export-snapshot.lua <SavedVariables.lua> [--key|snapshot-key]")
local selection = arg[2]

local function loadSavedVariables(path)
  local environment = {}
  local chunk
  if _VERSION == "Lua 5.1" then
    chunk = assert(loadfile(path))
    setfenv(chunk, environment)
  else
    chunk = assert(loadfile(path, "t", environment))
  end
  chunk()
  return assert(environment.apiRefersherDB, "apiRefersherDB was not found in " .. path)
end

local function sortedKeys(values)
  local keys = {}
  for key in pairs(values or {}) do
    keys[#keys + 1] = key
  end
  table.sort(keys, function(left, right)
    return tostring(left) < tostring(right)
  end)
  return keys
end

local function escape(value)
  return tostring(value == nil and "" or value)
    :gsub("\\", "\\\\")
    :gsub("\t", "\\t")
    :gsub("\r", "\\r")
    :gsub("\n", "\\n")
end

local function writeLine(kind, key, value)
  io.write(escape(kind), "\t", escape(key), "\t", escape(value), "\n")
end

local database = loadSavedVariables(savedVariablesPath)
local key = selection and selection ~= "--key" and selection or database.latest
local snapshot = assert(database.snapshots and database.snapshots[key], "snapshot was not found: " .. tostring(key))

if selection == "--key" then
  io.write(tostring(key), "\n")
  return
end

for _, name in ipairs(sortedKeys(snapshot.metadata)) do
  writeLine("META", name, snapshot.metadata[name])
end
for _, name in ipairs(sortedKeys(snapshot.loadedAddOns)) do
  writeLine("ADDON", name, "loaded")
end
for _, name in ipairs(sortedKeys(snapshot.earlyRuntime)) do
  writeLine("EARLY", name, snapshot.earlyRuntime[name])
end
for _, name in ipairs(sortedKeys(snapshot.runtime)) do
  writeLine("RUNTIME", name, snapshot.runtime[name])
end

local documentation = snapshot.documentation or {}
writeLine("DOC", "available", documentation.available and "true" or "false")
for _, name in ipairs(sortedKeys(documentation.systems)) do
  writeLine("SYSTEM", name, documentation.systems[name])
end
for _, name in ipairs(sortedKeys(documentation.functions)) do
  writeLine("FUNCTION", name, documentation.functions[name])
end
for _, name in ipairs(sortedKeys(documentation.events)) do
  writeLine("EVENT", name, documentation.events[name])
end
for _, name in ipairs(sortedKeys(documentation.tables)) do
  writeLine("TABLE", name, documentation.tables[name])
end
for _, id in ipairs(sortedKeys(snapshot.contracts)) do
  local contract = snapshot.contracts[id]
  local result = contract.passed and "PASS" or "FAIL"
  writeLine("CONTRACT", id, result .. "|" .. tostring(contract.details or "") .. "|" .. tostring(contract.description or ""))
end

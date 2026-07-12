local addonName = ...
local schemaVersion = 1

local function message(text)
  local prefix = "|cff71d5ffapiRefersher|r: "
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. tostring(text))
  else
    print(prefix .. tostring(text))
  end
end

local function resolvePath(path)
  local value = _G
  for part in tostring(path):gmatch("[^%.]+") do
    if type(value) ~= "table" then
      return nil
    end
    value = value[part]
    if value == nil then
      return nil
    end
  end
  return value
end

local function collectRuntimeSurface()
  local surface = {}
  for name, value in pairs(_G) do
    local valueType = type(value)
    surface[name] = valueType
    if valueType == "table" and name:match("^C_") then
      pcall(function()
        for childName, childValue in pairs(value) do
          if type(childName) == "string" then
            surface[name .. "." .. childName] = type(childValue)
          end
        end
      end)
    end
  end
  return surface
end

local earlyRuntimeSurface = collectRuntimeSurface()

local function loadAddOn(name)
  if C_AddOns and C_AddOns.LoadAddOn then
    return pcall(C_AddOns.LoadAddOn, name)
  elseif LoadAddOn then
    return pcall(LoadAddOn, name)
  end
  return false, "addon loader unavailable"
end

local function isAddOnLoaded(name)
  if C_AddOns and C_AddOns.IsAddOnLoaded then
    local ok, loadedOrLoading, loaded = pcall(C_AddOns.IsAddOnLoaded, name)
    return ok and (loaded or loadedOrLoading) and true or false
  elseif IsAddOnLoaded then
    local ok, loaded = pcall(IsAddOnLoaded, name)
    return ok and loaded and true or false
  end
  return false
end

local function ensureDocumentation()
  if not isAddOnLoaded("Blizzard_APIDocumentationGenerated") then
    loadAddOn("Blizzard_APIDocumentationGenerated")
  end
  return type(APIDocumentation) == "table"
end

local function fieldSignature(field)
  if not field then
    return "?"
  end
  local fieldType = field.InnerType and ((field.Type or "?") .. "<" .. field.InnerType .. ">") or (field.Type or "?")
  local suffix = ""
  if field.Nilable then
    suffix = suffix .. "?"
  end
  if field.Default ~= nil then
    suffix = suffix .. "=" .. tostring(field.Default)
  end
  if field.StrideIndex then
    suffix = suffix .. "#" .. tostring(field.StrideIndex)
  end
  return tostring(field.Name or "?") .. ":" .. fieldType .. suffix
end

local function fieldListSignature(fields)
  local values = {}
  for index, field in ipairs(fields or {}) do
    values[index] = fieldSignature(field)
  end
  return table.concat(values, ",")
end

local function documentationPath(api)
  local namespace = api.System and api.System.Namespace or ""
  if namespace and namespace ~= "" then
    return namespace .. "." .. tostring(api.Name)
  end
  return tostring(api.Name)
end

local function collectDocumentation()
  local docs = {
    available = false,
    systems = {},
    functions = {},
    events = {},
    tables = {},
  }
  if not ensureDocumentation() then
    return docs
  end

  docs.available = true
  for _, system in ipairs(APIDocumentation.systems or {}) do
    local namespace = system.Namespace or ""
    docs.systems[tostring(system.Name)] = namespace
  end
  for _, api in ipairs(APIDocumentation.functions or {}) do
    local path = documentationPath(api)
    docs.functions[path] = ("(%s)->(%s)|runtime=%s"):format(
      fieldListSignature(api.Arguments),
      fieldListSignature(api.Returns),
      type(resolvePath(path)))
  end
  for _, api in ipairs(APIDocumentation.events or {}) do
    local name = api.LiteralName or documentationPath(api)
    docs.events[tostring(name)] = fieldListSignature(api.Payload)
  end
  for _, api in ipairs(APIDocumentation.tables or {}) do
    local path = documentationPath(api)
    local details = fieldListSignature(api.Fields)
    if api.Type then
      details = tostring(api.Type) .. "|" .. details
    end
    docs.tables[path] = details
  end
  return docs
end

local function evaluateRequirement(requirement)
  local actualType = type(resolvePath(requirement.path))
  return actualType == requirement.expectedType, actualType
end

local function evaluateContracts()
  local results = {}
  for _, contract in ipairs(apiRefersherContracts or {}) do
    local passed = true
    local details = {}

    if contract.anyOf then
      passed = false
      for _, requirement in ipairs(contract.anyOf) do
        local ok, actualType = evaluateRequirement(requirement)
        details[#details + 1] = ("%s=%s"):format(requirement.path, actualType)
        if ok then
          passed = true
        end
      end
    end

    if contract.allOf then
      for _, requirement in ipairs(contract.allOf) do
        local ok, actualType = evaluateRequirement(requirement)
        details[#details + 1] = ("%s=%s"):format(requirement.path, actualType)
        if not ok then
          passed = false
        end
      end
    end

    results[contract.id] = {
      passed = passed and true or false,
      description = contract.description,
      details = table.concat(details, ";"),
    }
  end
  return results
end

local function collectLoadedAddOns()
  local loaded = {}
  local count
  if C_AddOns and C_AddOns.GetNumAddOns then
    count = C_AddOns.GetNumAddOns()
  elseif GetNumAddOns then
    count = GetNumAddOns()
  end
  for index = 1, count or 0 do
    local name
    if C_AddOns and C_AddOns.GetAddOnInfo then
      name = C_AddOns.GetAddOnInfo(index)
    elseif GetAddOnInfo then
      name = GetAddOnInfo(index)
    end
    if name and isAddOnLoaded(name) then
      loaded[name] = true
    end
  end
  return loaded
end

local function buildMetadata()
  local version, build, buildDate, interface = GetBuildInfo()
  return {
    addon = addonName or "apiRefersher",
    schema = schemaVersion,
    version = version,
    build = build,
    buildDate = buildDate,
    interface = interface,
    projectID = WOW_PROJECT_ID,
    locale = GetLocale and GetLocale() or "unknown",
    capturedAt = date and date("!%Y-%m-%dT%H:%M:%SZ") or tostring(time and time() or 0),
  }
end

local function snapshotKey(metadata)
  return ("%s-%s-project%s"):format(tostring(metadata.version), tostring(metadata.build), tostring(metadata.projectID))
end

local function ensureDatabase()
  apiRefersherDB = apiRefersherDB or {}
  apiRefersherDB.schema = schemaVersion
  apiRefersherDB.snapshots = apiRefersherDB.snapshots or {}
  return apiRefersherDB
end

local function runScan(quiet)
  local metadata = buildMetadata()
  local key = snapshotKey(metadata)
  local snapshot = {
    metadata = metadata,
    earlyRuntime = earlyRuntimeSurface,
    runtime = collectRuntimeSurface(),
    documentation = collectDocumentation(),
    contracts = evaluateContracts(),
    loadedAddOns = collectLoadedAddOns(),
  }
  local database = ensureDatabase()
  database.snapshots[key] = snapshot
  database.latest = key

  local passed, failed = 0, 0
  for _, result in pairs(snapshot.contracts) do
    if result.passed then
      passed = passed + 1
    else
      failed = failed + 1
    end
  end
  if not quiet then
    message(("snapshot %s captured: %d contracts passed, %d failed; /reload or logout to write SavedVariables"):format(key, passed, failed))
  end
  return snapshot
end

local function printStatus()
  local database = ensureDatabase()
  if not database.latest or not database.snapshots[database.latest] then
    message("no snapshot captured yet")
    return
  end
  local snapshot = database.snapshots[database.latest]
  local failed = {}
  for id, result in pairs(snapshot.contracts or {}) do
    if not result.passed then
      failed[#failed + 1] = id
    end
  end
  table.sort(failed)
  message(("latest snapshot: %s; documented API: %s; failed contracts: %s"):format(
    database.latest,
    snapshot.documentation and snapshot.documentation.available and "available" or "unavailable",
    #failed > 0 and table.concat(failed, ", ") or "none"))
end

SLASH_APIREFERSHER1 = "/apirefresher"
SlashCmdList.APIREFERSHER = function(input)
  local command = tostring(input or ""):match("^%s*(%S*)")
  command = command and command:lower() or ""
  if command == "scan" or command == "refresh" then
    runScan(false)
  elseif command == "status" then
    printStatus()
  elseif command == "clear" then
    local database = ensureDatabase()
    database.snapshots = {}
    database.latest = nil
    message("stored snapshots cleared")
  else
    message("commands: /apirefresher scan, /apirefresher status, /apirefresher clear")
  end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(_, event, name)
  if event == "ADDON_LOADED" and name == addonName then
    ensureDatabase()
  elseif event == "PLAYER_LOGIN" then
    local metadata = buildMetadata()
    local key = snapshotKey(metadata)
    local database = ensureDatabase()
    if not database.snapshots[key] then
      local callback = function()
        runScan(false)
      end
      if C_Timer and C_Timer.After then
        C_Timer.After(1, callback)
      else
        callback()
      end
    end
  end
end)

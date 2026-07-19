local root = assert(arg[1], "repository root is required")
local scheduled = {}
local eventFrame

SlashCmdList = {}
WOW_PROJECT_ID = 5
DEFAULT_CHAT_FRAME = {
  AddMessage = function() end,
}

function GetBuildInfo()
  return "2.5.6", "68575", "Jul 8 2026", 20506
end

function GetLocale()
  return "zhCN"
end

function date()
  return "2026-07-12T00:00:00Z"
end

function CreateFrame()
  local frame = {}
  function frame:RegisterEvent() end
  function frame:SetScript(_, callback)
    self.callback = callback
  end
  eventFrame = frame
  return frame
end

C_Timer = {
  After = function(_, callback)
    scheduled[#scheduled + 1] = callback
  end,
}

C_Container = {
  GetContainerNumSlots = function() return 16 end,
  GetContainerItemLink = function() return nil end,
  PickupContainerItem = function() end,
}

C_Spell = {
  GetSpellInfo = function() return nil end,
}

C_UnitAuras = {
  GetAuraDataByIndex = function(unit, index, filter)
    if unit == "player" and index == 1 and filter == "HELPFUL" then
      return {
        name = "Test Aura",
        icon = 123,
        applications = 2,
        dispelName = "Magic",
        duration = 30,
        expirationTime = 45,
        sourceUnit = "player",
        isStealable = false,
        nameplateShowPersonal = false,
        spellId = 456,
        canApplyAura = true,
        isBossAura = false,
      }
    end
  end,
}

function UnitAura(unit, index, filter)
  if unit == "player" and index == 1 and filter == "HELPFUL" then
    return "Test Aura", 123, 2, "Magic", 30, 45, "player", false, false, 456, true, false
  end
end

C_AddOns = {
  LoadAddOn = function() return true end,
  IsAddOnLoaded = function() return true, true end,
  GetNumAddOns = function() return 1 end,
  GetAddOnInfo = function() return "apiRefersher" end,
}

AuraUtil = {
  SetAuraBorderColor = function() end,
}
TargetFrame = {
  UpdateAuras = function() end,
}
function PickupInventoryItem() end
function CursorCanGoInSlot() return true end
function IsInventoryItemLocked() return false end
function hooksecurefunc() end

local containerSystem = { Name = "Container", Namespace = "C_Container" }
APIDocumentation = {
  systems = { containerSystem },
  functions = {
    {
      Name = "GetContainerNumSlots",
      System = containerSystem,
      Arguments = { { Name = "containerIndex", Type = "BagIndex" } },
      Returns = { { Name = "numSlots", Type = "number" } },
    },
  },
  events = {
    { Name = "BagUpdateDelayed", LiteralName = "BAG_UPDATE_DELAYED", Payload = {} },
  },
  tables = {
    { Name = "BagIndex", Type = "Enumeration", Fields = {} },
  },
}

assert(loadfile(root .. "/src/apiRefersher/Contracts.lua"))()
assert(loadfile(root .. "/src/apiRefersher/apiRefersher.lua"))("apiRefersher")
assert(eventFrame and eventFrame.callback, "event frame was not initialized")

eventFrame.callback(eventFrame, "ADDON_LOADED", "apiRefersher")
eventFrame.callback(eventFrame, "PLAYER_LOGIN")
while #scheduled > 0 do
  table.remove(scheduled, 1)()
end

assert(apiRefersherDB.latest == "2.5.6-68575-project5")
local snapshot = assert(apiRefersherDB.snapshots[apiRefersherDB.latest])
assert(snapshot.documentation.available)
assert(snapshot.documentation.functions["C_Container.GetContainerNumSlots"] == "(containerIndex:BagIndex)->(numSlots:number)|runtime=function")
assert(snapshot.contracts["aura-border-color"].passed)
assert(snapshot.contracts["unit-aura-tuple"].passed)
assert(snapshot.contracts["unit-aura-tuple"].details:find("matched=12", 1, true))
assert(snapshot.contracts["target-aura-refresh"].passed)
assert(snapshot.runtime["C_Container.GetContainerNumSlots"] == "function")

function UnitAura(unit, index, filter)
  if unit == "player" and index == 1 and filter == "HELPFUL" then
    return "Test Aura", 999, 2, "Magic", 30, 45, "player", false, false, 456, true, false
  end
end
SlashCmdList.APIREFERSHER("scan")
snapshot = assert(apiRefersherDB.snapshots[apiRefersherDB.latest])
assert(not snapshot.contracts["unit-aura-tuple"].passed)
assert(snapshot.contracts["unit-aura-tuple"].details:find("mismatch=icon", 1, true))

print("addon scan test passed")

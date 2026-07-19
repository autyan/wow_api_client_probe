apiRefersherContracts = {
  {
    id = "aura-border-color",
    description = "An aura debuff-color implementation is available.",
    anyOf = {
      { path = "AuraUtil.SetAuraBorderColor", expectedType = "function" },
      { path = "DebuffTypeColor", expectedType = "table" },
    },
  },
  {
    id = "unit-aura-tuple",
    description = "Legacy UnitAura values match the structured aura API for a live sample.",
    allOf = {
      { path = "UnitAura", expectedType = "function" },
      { path = "C_UnitAuras.GetAuraDataByIndex", expectedType = "function" },
    },
    probe = "unit-aura-tuple",
  },
  {
    id = "target-aura-refresh",
    description = "The target frame exposes an aura refresh entry point.",
    anyOf = {
      { path = "TargetFrame.UpdateAuras", expectedType = "function" },
      { path = "TargetFrame_UpdateAuras", expectedType = "function" },
    },
  },
  {
    id = "container-read",
    description = "Container slots and links can be inspected.",
    allOf = {
      { path = "C_Container.GetContainerNumSlots", expectedType = "function" },
      { path = "C_Container.GetContainerItemLink", expectedType = "function" },
    },
  },
  {
    id = "container-pickup",
    description = "Container items can be moved by an addon.",
    anyOf = {
      { path = "C_Container.PickupContainerItem", expectedType = "function" },
      { path = "PickupContainerItem", expectedType = "function" },
    },
  },
  {
    id = "inventory-swap",
    description = "Equipment slots support cursor-based swaps.",
    allOf = {
      { path = "PickupInventoryItem", expectedType = "function" },
      { path = "CursorCanGoInSlot", expectedType = "function" },
      { path = "IsInventoryItemLocked", expectedType = "function" },
    },
  },
  {
    id = "spell-info",
    description = "Spell metadata can be queried through a modern or legacy API.",
    anyOf = {
      { path = "C_Spell.GetSpellInfo", expectedType = "function" },
      { path = "GetSpellInfo", expectedType = "function" },
    },
  },
  {
    id = "addon-loader",
    description = "Load-on-demand Blizzard API documentation can be loaded.",
    anyOf = {
      { path = "C_AddOns.LoadAddOn", expectedType = "function" },
      { path = "LoadAddOn", expectedType = "function" },
    },
  },
  {
    id = "secure-hook",
    description = "Secure post-hooks are available to compatibility patches.",
    allOf = {
      { path = "hooksecurefunc", expectedType = "function" },
    },
  },
}

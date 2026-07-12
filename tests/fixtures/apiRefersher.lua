apiRefersherDB = {
  schema = 1,
  latest = "2.5.6-68575-project5",
  snapshots = {
    ["2.5.6-68575-project5"] = {
      metadata = {
        addon = "apiRefersher",
        schema = 1,
        version = "2.5.6",
        build = "68575",
        interface = 20506,
        projectID = 5,
        locale = "zhCN",
      },
      loadedAddOns = {
        apiRefersher = true,
      },
      earlyRuntime = {
        C_Container = "table",
      },
      runtime = {
        ["C_Container.GetContainerNumSlots"] = "function",
      },
      documentation = {
        available = true,
        systems = {
          Container = "C_Container",
        },
        functions = {
          ["C_Container.GetContainerNumSlots"] = "(containerIndex:BagIndex)->(numSlots:number)|runtime=function",
        },
        events = {
          BAG_UPDATE_DELAYED = "",
        },
        tables = {
          BagIndex = "Enumeration|",
        },
      },
      contracts = {
        ["aura-border-color"] = {
          passed = true,
          description = "An aura debuff-color implementation is available.",
          details = "AuraUtil.SetAuraBorderColor=function",
        },
      },
    },
  },
}

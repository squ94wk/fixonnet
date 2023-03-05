function(sup) {
  dashboard:: function(selector)
    local selectorFunc = if std.isString(selector) then function(key, dashboard) key == selector else if std.isFunction(selector) then function(key, dashboard) selector(key, dashboard);
    {
      drop:: function()
        sup {
          dashboards: {
            [if !selectorFunc(key, sup.dashboards[key]) then key]: sup.dashboards[key]
            for key in std.objectFields(sup.dashboards)
          }
        },
      rename:: function(newName)
        sup {
          dashboards: {
            [if selectorFunc(key, sup.dashboards[key]) then newName else key]: sup.dashboards[key]
            for key in std.objectFields(sup.dashboards)
          }
        },
      patch:: function(patch)
        local patchFunc = if std.isFunction(patch) then patch else function(dashboard) dashboard + patch;
        sup {
          dashboards: {
            [key]: if selectorFunc(key, sup.dashboards[key]) then patchFunc(sup.dashboards[key]) else sup.dashboards[key]
            for key in std.objectFields(sup.dashboards)
          }
        },
    },
}

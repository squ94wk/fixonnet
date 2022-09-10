local rules = function(sup) {
  add:: function(group)
    sup {
      rules+: {
        groups+: [group],
      },
    },
  group:: function(selector)
    local selectorFunc = if std.isString(selector) then function(group) group.name == selector else if std.isFunction(selector) then function(group) selector(group);
    {
      drop:: function() null,
      rename:: function(newName)
        sup {
          rules+: {
            groups: [
              if selectorFunc(group) then
              group {
                name: newName,
              }
              else group
              for group in super.groups
            ],
          },
        },
      add:: function(rule)
        sup {
          rules+: {
            groups: [
              if selectorFunc(group) then
              group {
                rules+: [rule],
              }
              else group
              for group in super.groups
            ],
          },
        },
      rules:: function(cond) {
        patch:: function(patch)
          sup {
            rules+: {
              groups: [
                if selectorFunc(group) then
                group {
                  rules: [
                    if cond(rule) then (if std.isFunction(patch) then patch(rule) else rule + patch) else rule for rule in group.rules
                  ],
                }
                else group
                for group in super.groups
              ],
            },
          },
        drop:: function()
          sup {
            rules+: {
              groups: [
                if selectorFunc(group) then
                group {
                  rules: [
                    rule for rule in group.rules if !cond(rule)
                  ],
                }
                else group
                for group in super.groups
              ],
            },
          },
      },
    },
};

local merge = function(a, b)
  if std.isArray(b) then
    if b == [] then
      // nothing to merge (anymore)
      a
    else
      // recursively merge with one element at a time
      merge(merge(a, b[0]), b[1:])
  else
    local mergeRules = function(rules)
      local reducer = function(res, rule)
        local collisions = [r for r in res if ("alert" in r && "alert" in rule && r.alert == rule.alert) || ("record" in r && "record" in rule && r.record == rule.record)];
        if [] == collisions then
          res + [rule]
        else
          res
      ;
      std.foldl(reducer, rules, [])
    ;

    local mergeGroups = function(groups)
      local reducer = function(res, group)
        local collisions = [g for g in res if g.name == group.name];
        if [] == collisions then
          res + [group]
        else
          local existing = collisions[0];
          [g for g in res if g.name != group.name] + [{
            name: existing.name,
            rules: mergeRules(existing.rules + group.rules),
          }]
      ;
      std.foldl(reducer, groups, [])
    ;

    a {
      rules: {
        groups: mergeGroups(a.rules.groups + b.rules.groups),
      },
    }
;

local normalize = function(mixin)
  local fillNulls = {
    rules: {},
    dashboards: {},
    grafanaDashboards: {},
    prometheusAlerts: {},
    prometheus_alerts: {},
    prometheusRules: {},
  } + mixin;
  {
    dashboards: fillNulls.dashboards + fillNulls.grafanaDashboards,
    rules: fillNulls.rules + fillNulls.prometheusRules + fillNulls.prometheusAlerts + fillNulls.prometheus_alerts,
  };

function(mixin)
  normalize(mixin) {
    drop:: function(cond=function() true)
      local condFunc = if std.isFunction(cond) then cond else function() cond;
      if condFunc() then null else self,
    rules+: rules(self),
    merge:: function(others)
      merge(self, others)
  }

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
    rules: {
      groups+: [],
    },
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

{
  merge: merge,
  normalize: normalize,
}

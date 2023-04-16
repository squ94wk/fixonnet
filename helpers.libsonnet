// This file contains helper functions.

// normalize converts raw data into a common format.
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

// merge deeply combines two datasets.
local merge = function(a, b)
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
    dashboards: a.dashboards + b.dashboards,
  }
;

// apply applies fixups expressed as functions
// See fn.libsonnet
local apply = function(x) function(funcs)
  local funcList = if std.isArray(funcs) then funcs else [funcs];
  local _apply = function(m, fs)
    if std.length(fs) == 0 then
      m
    else
      _apply(fs[0](m), fs[1:]) tailstrict;
  _apply(x, funcList)
;

{
  normalize: normalize,
  merge: merge,
  apply: apply,
}

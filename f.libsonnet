// This file exports the "augment" function.
// It enriches raw data with Prometheus rules and Grafana dashboards with functions that modify the data.

local fn = import 'fn.libsonnet';
local helpers = import 'helpers.libsonnet';

local rules = function(x) {
  add:: function(group)
    fn.rules.add(group)(x),
  group:: function(selector)
    {
      drop:: function()
        fn.rules.group(selector).drop()(x),
      rename:: function(name)
        fn.rules.group(selector).rename(name)(x),
      add:: function(rule)
        fn.rules.group(selector).add(rule)(x),
      rule:: function(ruleSelectorFunc) {
        patch:: function(patch)
          fn.rules.group(selector).rule(ruleSelectorFunc).patch(patch)(x),
        drop:: function()
          fn.rules.group(selector).rule(ruleSelectorFunc).drop()(x),
      },
    },
};

local dashboards = function(x) {
  dashboard:: function(selector)
    {
      drop:: function()
        fn.dashboards.dashboard(selector).drop()(x),
      rename:: function(name)
        fn.dashboards.dashboard(selector).rename(name)(x),
      patch:: function(patch)
        fn.dashboards.dashboard(selector).patch(patch)(x),
    }
};

local augment = function(x) helpers.normalize(x) + {
  drop:: function()
    augment({}),
  rules+: rules(self),
  dashboards+: dashboards(self),
  merge:: function(others)
    local merge = function(a, b)
      if std.isArray(b) then
        if b == [] then
          // nothing to merge (anymore)
          a
        else
          // recursively merge with one element at a time
          merge(merge(a, b[0]), b[1:]) tailstrict
      else
        helpers.merge(a, helpers.normalize(b))
      ;
    augment(merge(self, others))
    ,
  apply:: function(funcs, condition=function(x) true)
    // allow bool or function() bool
    local conditionFunc = if std.isFunction(condition) then condition else function(x) condition;
    if conditionFunc(self) then
      helpers.apply(self)(funcs)
    else
      self
    ,
};

augment

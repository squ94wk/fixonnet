local fn = import 'fn.libsonnet';
local dashboards = import 'dashboards.libsonnet';
local helpers = import 'helpers.libsonnet';

local rules = function(sup) {
  add:: function(group)
    fn.rules.add(group)(sup),
  group:: function(selector)
    local selectorFunc = if std.isString(selector) then function(group) group.name == selector else if std.isFunction(selector) then function(group) selector(group);
    {
      drop:: function()
        fn.rules.group(selector).drop()(sup),
      rename:: function(name)
        fn.rules.group(selector).rename(name)(sup),
      add:: function(rule)
        fn.rules.group(selector).add(rule)(sup),
      rules:: function(ruleSelectorFunc) {
        patch:: function(patch)
          fn.rules.group(selector).rules(ruleSelectorFunc).patch(patch)(sup),
        drop:: function()
          fn.rules.group(selector).rules(ruleSelectorFunc).drop()(sup),
      },
    },
};

function(mixin)
  helpers.normalize(mixin) {
    drop:: function(cond=function() true)
      local condFunc = if std.isFunction(cond) then cond else function() cond;
      if condFunc() then null else self,
    rules+: rules(self),
    dashboards+: dashboards(self),
    merge:: function(others)
      helpers.merge(self, others),
    apply:: function(funcs)
      local funcList = if std.isArray(funcs) then funcs else [funcs];
      local _apply = function(m, fs)
        if std.length(fs) == 0 then
          m
        else
          _apply(fs[0](m), fs[1:]) tailstrict;
      _apply(self, funcList),
  }

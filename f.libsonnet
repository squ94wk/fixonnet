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
    drop:: function()
      fn.drop()(self),
    rules+: rules(self),
    dashboards+: dashboards(self),
    merge:: function(others)
      helpers.merge(self, others),
    apply:: function(funcs, condition=function(x) true)
      local conditionFunc = if std.isFunction(condition) then condition else function(x) condition;
      if conditionFunc(self) then
        helpers.apply(self)(funcs)
      else
        self
      ,
  }

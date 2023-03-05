local rules = import 'rules.libsonnet';
local dashboards = import 'dashboards.libsonnet';
local helpers = import 'helpers.libsonnet';

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

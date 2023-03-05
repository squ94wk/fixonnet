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
      local _apply = function(m, funcs)
        if std.length(funcs) == 0 then
          m
        else
          _apply(funcs[0](m), funcs[1:]) tailstrict;
      _apply(self, funcs),
  }

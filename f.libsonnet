// This file exports the "augment" function.
// It enriches raw data with Prometheus rules and Grafana dashboards with functions that modify the data.

local helpers = import 'helpers.libsonnet';

local rules = function(dataset) {
  add:: function(group)
    dataset {
      rules+: {
        groups+: [group],
      },
    },
  group:: function(selector)
    local selectorFunc = if std.isString(selector) then function(group) group.name == selector else if std.isFunction(selector) then function(group) selector(group);
    {
      drop:: function()
        dataset {
          rules+: {
            groups: [
              group
              for group in super.groups
              if !selectorFunc(group)
            ],
          },
        },
      rename:: function(newName)
        dataset {
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
        local addedRules = if std.isArray(rule) then rule else [rule];
        dataset {
          rules+: {
            groups: [
              if selectorFunc(group) then
              group {
                rules+: addedRules,
              }
              else group
              for group in super.groups
            ],
          },
        },
      rule:: function(ruleSelectorFunc) {
        drop:: function()
          dataset {
            rules+: {
              groups: [
                if selectorFunc(group) then
                  group {
                    rules: [
                      rule
                      for rule in group.rules
                      if !ruleSelectorFunc(rule)
                    ],
                  }
                else group
                for group in super.groups
              ],
            },
          },
        patch:: function(patch)
          local patchFunc = if std.isFunction(patch) then patch else function(rule) rule + patch;
          dataset {
            rules+: {
              groups: [
                if selectorFunc(group) then
                  group {
                    rules: [
                      if ruleSelectorFunc(rule) then
                        patchFunc(rule)
                      else rule
                      for rule in group.rules
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

local dashboards = function(dataset)
  {
    dashboard:: function(selector)
      local selectorFunc = if std.isString(selector) then function(key, dashboard) key == selector else if std.isFunction(selector) then function(key, dashboard) selector(key, dashboard);
      {
        drop:: function()
          local d = dataset {
            dashboards: {
              [if !selectorFunc(key, dataset.dashboards[key]) then key]: dataset.dashboards[key]
              for key in std.objectFields(dataset.dashboards)
            },
          };
          d {
            dashboards+: dashboards(d),
          },
        rename:: function(newName)
          local d = dataset {
            dashboards: {
              [if selectorFunc(key, dataset.dashboards[key]) then newName else key]: dataset.dashboards[key]
              for key in std.objectFields(dataset.dashboards)
            },
          };
          d {
            dashboards+: dashboards(d),
          },
        patch:: function(patch)
          local patchFunc = if std.isFunction(patch) then patch else function(dashboard) dashboard + patch;
          local d = dataset {
            dashboards: {
              [key]: if selectorFunc(key, dataset.dashboards[key]) then patchFunc(dataset.dashboards[key]) else dataset.dashboards[key]
              for key in std.objectFields(dataset.dashboards)
            },
          };
          d {
            dashboards+: dashboards(d),
          },
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

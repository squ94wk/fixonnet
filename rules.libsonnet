local fn = import 'fn.libsonnet';

function(sup) {
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
        local addedRules = if std.isArray(rule) then rule else [rule];
        sup {
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
}

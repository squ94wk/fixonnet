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
        fn.rules.group(selector).add(rule)(sup),
      rules:: function(ruleSelectorFunc) {
        patch:: function(patch)
          fn.rules.group(selector).rules(ruleSelectorFunc).patch(patch)(sup),
        drop:: function()
          sup {
            rules+: {
              groups: [
                if selectorFunc(group) then
                group {
                  rules: [
                    rule for rule in group.rules if !ruleSelectorFunc(rule)
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

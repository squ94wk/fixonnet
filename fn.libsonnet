local helpers = import 'helpers.libsonnet';

{
  drop:: function() function(x) helpers.normalize({}),
  rules+: {
    add:: function(group) function(x)
      x {
        rules+: {
          groups+: [group],
        },
      },
    group:: function(selector)
      local selectorFunc = if std.isString(selector) then function(group) group.name == selector else if std.isFunction(selector) then function(group) selector(group);
      {
        drop:: function() function(x)
          x {
            rules+: {
              groups: [
                group
                for group in super.groups
                if !selectorFunc(group)
              ],
            },
          },
        rename:: function(newName) function(x)
          x {
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
        add:: function(rule) function(x)
          local addedRules = if std.isArray(rule) then rule else [rule];
          x {
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
        rules:: function(ruleSelectorFunc) {
          patch:: function(patch) function(x)
            local patchFunc = if std.isFunction(patch) then patch else function(rule) rule + patch;
            x {
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
          drop:: function() function(x)
            x {
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
        },
      },
    },
}

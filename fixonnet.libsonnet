local rules = function(sup) {
  add:: function(group)
    sup {
      rules+: {
        groups+: [group],
      },
    },
  group:: function(name)
    {
      drop:: function() null,
      rename:: function(newName)
        sup {
          rules+: {
            groups: [
              if group.name == name then
              group {
                name: newName,
              }
              else group
              for group in super.groups
            ],
          },
        },
      add:: function(rule)
        sup {
          rules+: {
            groups: [
              if group.name == name then
              group {
                rules+: [rule],
              }
              else group
              for group in super.groups
            ],
          },
        },
      rules:: function() null,
    },
};

function(mixin)
  mixin {
    drop:: function() null,
    rules+: rules(self),
  }

// This file exports function generators for modifying data analogous to the ones found in f.libsonnet.
// Thereby separating the construction of functions from applying them.
//
// Functions function(x) are meant to be applied through f(raw).apply(...).

{
  drop:: function() function(x) x.drop(),
  rules: {
    add:: function(group) function(x)
      x.rules.add(group),
    group:: function(selector)
      {
        drop:: function() function(x)
          x.rules.group(selector).drop(),
        rename:: function(name) function(x)
          x.rules.group(selector).rename(name),
        add:: function(rule) function(x)
          x.rules.group(selector).add(rule),
        rule:: function(ruleSelectorFunc) {
          drop:: function() function(x)
            x.rules.group(selector).rule(ruleSelectorFunc).drop(),
          patch:: function(patch) function(x)
            x.rules.group(selector).rule(ruleSelectorFunc).patch(patch),
        },
      },
    },
  dashboards: {
    dashboard:: function(selector)
      {
        drop:: function() function(x)
          x.dashboards.dashboard(selector).drop(),
        rename:: function(name) function(x)
          x.dashboards.dashboard(selector).rename(name),
        patch:: function(patch) function(x)
          x.dashboards.dashboard(selector).patch(patch),
      }
  },
}

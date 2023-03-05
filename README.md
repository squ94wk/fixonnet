# Fixonnet

A jsonnet library for easily patching monitoring mixins.

Supported:
```
f(raw).drop()
f(raw).rules.add(group)

f(raw).rules.group("group").rename("newGroup")
f(raw).rules.group("group").drop()
f(raw).rules.group("group").add(rule)
f(raw).rules.group("group").add([rule, ...])

f(raw).rules.group("group").rules(cond).drop()
f(raw).rules.group("group").rules(cond).patch(patch)
f(raw).rules.group("group").rules(cond).patch(patchFunc)

f(raw).rules.groups(condition).<group op>()

f(raw).merge(raw)

f(raw).dashboards.dashboard('name.json').drop()
f(raw).dashboards.dashboard('name.json').rename('other.json')
f(raw).dashboards.dashboard('name.json').patch({title: "Some Overview"})
f(raw).dashboards.dashboard('name.json').patch(function(dashboard) dashboard {title: "Some Overview"})
f(raw).dashboards.dashboard(function(key, dashboard) dashboard.title != "").<dashboard op>()

f(raw).apply([]fixup)
```

Future:
```
more dashboards functions
```

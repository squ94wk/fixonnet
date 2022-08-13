# Fixonnet

A jsonnet library for easily patching monitoring mixins.

Supported:
```
f(raw).drop()
f(raw).rules.add(group)

f(raw).rules.group("group").rename("newGroup")
f(raw).rules.group("group").drop()
f(raw).rules.group("group").add(rule)

f(raw).rules.group("group").rules(cond).drop()
f(raw).rules.group("group").rules(cond).patch(patch)
f(raw).rules.group("group").rules(cond).patch(patchFunc)

f(raw).rules.groups(condition).<group op>()
```

Future:
```
f(raw).merge(raw)
f(raw).apply([]fixup)
```

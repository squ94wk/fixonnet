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
```

Future:
```
f(raw).rules.group("group").rules(cond).patch(newRule)
f(raw).rules.group("group").rules(cond).patchFunc(patchFunc)
f(raw).merge(raw)
f(raw).apply([]fixup)
f(raw).rules.groups(condition).<group op>()
```

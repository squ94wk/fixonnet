# Fixonnet

A jsonnet library for easily patching monitoring mixins.

## Installation

The library needs to be in one of the import paths passed to `jsonnet`.

A recommended way is to use jsonnet bundler.

## Usage

```jsonnet
// Import the library
local f = (import 'github.com/squ94wk/fixonnet/fixonnet.libsonnet').f;

// Wrap your data (e.g. imported mixin) into `f()`:
f((import 'mixin.jsonnet') + $._config)
```

This will:

1.  Normalize the data into a common format
2.  Add functions to the object to perform actions with the data
    
    Functions allow to precisely select and modify (drop, add, patch, ...) rules and dashboards.
    The functions are accessed through hidden fields in the object and can be chained arbitrarily.

### Example

```jsonnet
f('mixin.jsonnet')
  .rules.group('groupName').drop()
  .dashboards.dashboard(function(d) d.title == 'Grafana').patch({title: 'Grafana Overview'})
```

The first chain will select a whole group of rules with the name "groupName" and remove it.

The second chain will change the title of a dashboard.

## Functions

### Base

* `f(raw)`

    Functions become available on a dataset by applying `f` on it.

    This normalizes the data and adds functions as hidden fields.

    From:

    ```jsonnet
    {
        prometheusRules: {
            groups: [...],
        },
        prometheusAlerts: {
            groups: [...],
        },
        prometheus_alerts: {
            groups: [...],
        },
        grafanaDashboards: {
            'dashboard.json': '...',
        },
    }
    ```

    To:

    ```jsonnet
    {
        rules: {
            groups: [...],
        },
        dashboards: {
            'dashboard.json': '...',
        },
    }
    ```

* `f(...).merge(raw)`

    This combines rules and dashboards from another source with the existing dataset.

    It merges nested groups with the same name.

### Rules

* `f(...).rules.add(group)`

    This allows you to add an entire group of rules to the dataset.

* `f(...).rules.group('groupName' | selectorFunction: function(group) bool)`

    _Takes a string or a function as an argument._

    Selects a group based on its name or through a selector function that takes the group as an input.
    The following action will be applied to all groups for which the function returns `true`.

* `f(...).rules.group(...).drop()`

    Removes matching groups.

* `f(...).rules.group(...).rename('groupName')`

    _Takes a string as an argument._

    This changes the name of a group.

* `f(...).rules.group(...).add(rule | [rule, ...])`

    Takes a single rule object or an array of rules to the group(s).

* `f(...).rules.group(...).rule(conditionFunction: function(rule) bool)`

    Applies the function to every rule in the group.
    The following action will be applied to all rules for which the function returns `true`.

* `f(...).rules.group(...).rule(...).drop()`

    Any matching rule in matching groups is removed.

* `f(...).rules.group(...).rule(...).patch(patch: {} | patchFunction: function(rule) rule)`

    _Takes either a rule object or a function as an argument._

    If the argument is:

    * an object, matching rules is merged with it.
    * a function, matching rules are replaced by the value of the function after being applied to the rule.

* `fn.<op>()`

    Substituting `f` for `fn` for (almost) any function described above will yield a function that can be applied to data.

    _Prerequisite_

    ```jsonnet
    local fn = (import 'github.com/squ94wk/fixonnet/fixonnet.libsonnet').fn;
    ```

    The following are equivalent:

    ```jsonnet
    local data = f(raw);

    // applied directly
    data.<op>(...)

    // expressed as a function
    fn.<op>(...)(data)

    // applied using `apply`
    data.apply(fn.<op>(...))
    ```

### Dashboards

* `f(...).dashboards.dashboard('dashboardKey' | selectorFunction: function(key, dashboard) bool)`

    _Takes either a string or a function as argument._

    Selects dashboard(s) based on either its key (usually a filename) or a function that takes the key and the dashboard itself.
    The following action will be applied to all dashboards for which the function returns `true`.

* `f(...).dashboards.dashboard(...).drop()`

    Any matching dashboard will be removed.

* `f(...).dashboards.dashboard(...).rename('newKey')`

    The matching dashboard will be placed in `.dashboards` under a new key.

* `f(...).dashboards.dashboard(...).patch(patch | patchFunction: function(dashboard) dashboard)`

    _Takes either a rule object or a function as an argument._

    If the argument is:

    * an object, matching dashboards is merged with it.
    * a function, matching dashboards are replaced by the value of the function after being applied to the dashboard.

### Additional

* `f(...).apply(fixup | [fixup, ...], condition: bool | function() bool (optional, default=true))`

    _Takes either a fixup function or an array thereof and a mandatory argument._
    _The named argument "condition" may be specified optionally and defaults to `true`.

    When the condition evaluates to `false`, the function becomes a noop.

    The "fixup"s are functions that take a dataset as an argument.
    Notably, values yielded by functions from `fn`, are candidates for fixups.

    This allows different advanced scenarios:

    1.  Conditionally applying actions
    2.  Predefining patches and applying them on multiple datasets
    3.  Organizing patched apart from where they're applied (e.g. different files)

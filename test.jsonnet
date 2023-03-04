local f = import './fixonnet.libsonnet';

local rules = [
  {
    record: "rule%d" % i,
    expr: "vector(%d)" % i,
  } for i in std.range(0, 10)
];

local alerts = [
  {
    alert: "alert%d" % i,
    expr: "vector(%d)" % i,
  } for i in std.range(0, 10)
];

local dashboards = {
  ["d%d" % i]: {
    title: "dashboard %d" % i,
  } for i in std.range(0, 10)
};

local group0 = {
  name: "group0",
  rules: [
    rules[0],
  ],
};

local group1 = {
  name: "group1",
  rules: [
    rules[1],
  ],
};

local group2 = {
  name: "group2",
  rules: [
    rules[2],
    alerts[0],
  ],
};

local mixin0 = {
  dashboards: {},
  rules: {
    groups: [
      group0,
    ],
  },
};

local mixin1 = {
  dashboards: {},
  rules: {
    groups: [
      group2,
      group1,
    ],
  },
};

local mixin2 = {
  dashboards: {
    dashboard0: dashboards.d0,
  },
  rules: {
    groups: [
      group2,
      group1,
    ],
  },
};

local tests = [
  {
    name: "f() retains input",
    expr:: function() f(mixin0),
    test: function(res) res == mixin0,
  },
  {
    name: "drop() returns null",
    expr:: function() f(mixin0).drop(),
    test: function(res) res == null,
  },
  {
    name: "drop() is noop if condition is false",
    expr:: function() f(mixin0).drop(function() false),
    test: function(res) res == mixin0,
  },
  {
    name: "rules.add() adds group",
    expr:: function() f(mixin0).rules.add(group1),
    test: function(res) std.length(res.rules.groups) == 2,
  },
  {
    name: "rules.group(name).rename changes name",
    expr: function() f(mixin0).rules.group("group0").rename("group2"),
    test: function(res) res.rules.groups[0].name == "group2",
  },
  {
    name: "rules.group(name).add(newRule) adds rule",
    expr: function() f(mixin0).rules.group("group0").add(rules[1]),
    test: function(res) std.length(res.rules.groups[0].rules) == 2 && res.rules.groups[0].rules[1] == rules[1],
  },
  {
    name: "rules.group(name).rules(cond).drop() drops rule",
    expr: function() f(mixin1).rules.group("group2").rules(function(rule) "alert" in rule && rule.alert == "alert0").drop(),
    test: function(res) std.length(res.rules.groups[0].rules) == 1,
  },
  {
    name: "rules.group(name).rules(cond).patch(patch) patches rule",
    expr: function() f(mixin1).rules.group("group2").rules(function(rule) "alert" in rule && rule.alert == "alert0").patch({alert: "alert1"}),
    test: [
      function(res) std.length(res.rules.groups[0].rules) == 2,
      function(res) res.rules.groups[0].rules[1].alert == "alert1",
    ],
  },
  {
    name: "rules.group(name).rules(cond).patch(patchFunc) patches rule using a function",
    expr: function() f(mixin1).rules.group("group2").rules(function(rule) "alert" in rule && rule.alert == "alert0").patch(function(rule) rule + {alert: std.strReplace(rule.alert, "alert", "funk")}),
    test: [
      function(res) std.length(res.rules.groups[0].rules) == 2,
      function(res) res.rules.groups[0].rules[1].alert == "funk0",
    ],
  },
  {
    name: "rules.group(func).rename changes name",
    expr: function() f(mixin1).rules.group(function(group) group.name == "group2").rename("group1"),
    test: [
      function(res) std.length(res.rules.groups) == 2,
      function(res) res.rules.groups[0].name == "group1",
    ],
  },
  {
    name: "f(a).merge(b) merges deeply",
    expr: function() f(mixin0).merge([f(mixin1), f(mixin1)]),
    test: [
      // Merge mixin1
      function(res) std.length(res.rules.groups) == 3,
      // Discard duplicate nested rules
      function(res) std.length(res.rules.groups[1].rules) == 2,
    ],
  },
  {
    name: "f(a).dashboards.dashboard(name).rename(newName) renames dashboard",
    expr: function() f(mixin2).dashboards.dashboard('dashboard0').rename('some'),
    test: [
      function(res) 'some' in res.dashboards,
      function(res) res.dashboards["some"] == dashboards.d0,
    ],
  },
];

local eval = function(case)
  local value = case.expr();
  {
    name: case.name,
  } + if (std.isArray(case.test) && [] == std.find(false, [test(value) for test in case.test])) || (std.isFunction(case.test) && case.test(value)) then {
    result: 'PASSED',
  } else {
    result: 'FAILED',
    actual: value,
  }
;

[test for test in [
  eval(case) for case in tests
] if test.result == 'FAILED']
